module TestStrategy
	class SuperiorityDOM < BaseIterationApprox
    include Approx::HypothesisDOM
    include Approx::Superiority

    def self.properties
      {
        :distribution => :normal,
        :hypothesis => :superiority,
        :statistics => :difference_of_means
      }
    end

    def variables=(variables)
      super(variables)

      extract_sided(variables)
      extract_delta(variables)
      extract_variance(variables)
    end

    def test data
      _T = ((data[0].mean - data[1].mean)/Math.sqrt(data.pooled_variance))*
        Math.sqrt((data[0].size*data[1].size)/(data.size))
      if @sided == 2
        quantile = StudentT.quantile(1-(@alpha/2), data.size-2)
        return _T.abs >= quantile, _T
      elsif @sided == 1
        quantile = StudentT.quantile(1-@alpha, data.size-2)
        return _T >= quantile, _T
      else
        raise "fail"
      end
    end
    
  end
end
