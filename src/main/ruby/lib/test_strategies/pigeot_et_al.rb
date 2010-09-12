module TestStrategy
  class PigeotEtAl < Base
    include IterationHelper

    def self.properties
      {
        :strategy => :pigeot_et_al
      }
    end

    def variables=(variables)
      super(variables)
      extract_variance(variables)

      @theta = variables[:theta] || 0.8
      @ceffect = variables[:ceffect] || @arms[1].mean - @arms[2].mean
      @teffect = variables[:teffect] || (@arms[0].mean - @arms[2].mean)/@ceffect

      @c_c = @arms[1].weight.to_f / @arms[0].weight.to_f
      @c_p = @arms[2].weight.to_f / @arms[0].weight.to_f
    end

    def sample_size vars
      theta = vars[:theta] || @theta
      variance = vars[:variance] || @variance
      teffect = vars[:teffect] || @teffect
      ceffect = vars[:ceffect] || @ceffect
      
      epsilon = Math.sqrt(variance) / ceffect

      t2 = (1 + (theta**2)/@c_c + ((1-theta)**2)/(@c_p))
      t3 = (epsilon/(teffect - theta))**2
      ratio = (1.0 + @c_c + @c_p)

      gauss_t_distribution_iteration(3, 1-@alpha, 1-@beta, t2*t3, ratio)
    end

    def test data
      atheta = 1-@theta

      numerator = (data[0].mean - (@theta * data[1].mean) - (atheta*data[2].mean))
      _S =  Math.sqrt(data.pooled_variance)
      denumerator =  _S * Math.sqrt((1.0/data[0].size) +((@theta**2)/data[1].size)+ ((atheta**2)/data[2].size))

      _T = numerator/denumerator
      
      v = data[0].size + data[1].size + data[2].size - 3

      return _T > StudentT.quantile(1-@alpha, v), _T
    end
  end
end
