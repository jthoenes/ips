module TestStrategy
  class NonInferiorityDOM < BaseIterationApprox
    include Approx::HypothesisDOM

    def _B(vars)
      _Delta = vars[:Delta] || @_Delta
      [_Delta]
    end

    def variables=(variables)
      super(variables)
      extract_delta(variables)
      extract_variance(variables)

      @_Delta = variables[:Delta] || -0.1
    end

    def self.properties
      {
        :distribution => :normal,
        :hypothesis => :non_inferiority,
        :statistics => :difference_of_means
      }
    end

    def test data
      @logger.debug{"Test: alpha=#{@alpha}, Delta=#{@_Delta}"}
      @logger.debug{"Test: (#{data[0].name}) mean=#{data[0].mean}, var=#{data[0].var}, n=#{data[0].size}"}
      @logger.debug{"Test: (#{data[1].name}) mean=#{data[1].mean}, var=#{data[1].var}, n=#{data[1].size}"}

      sample_count = data[0].size + data[1].size
      _T = ((data[0].mean - data[1].mean-@_Delta)/Math.sqrt(data.pooled_variance))*
        Math.sqrt((data[0].size*data[1].size)/(sample_count))

      @logger.debug{"Test: T=#{_T} >= #{StudentT.quantile(1-@alpha, sample_count - 2)}"}
      return _T >= StudentT.quantile(1-@alpha, sample_count - 2), _T
    end
  end
end
