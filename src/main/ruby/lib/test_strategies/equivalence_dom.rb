module TestStrategy
  class EquivalenceDOM < BaseIterationApprox
    include Approx::Equivalence
    include Approx::HypothesisDOM

    def self.properties
      {
        :distribution => :normal,
        :hypothesis => :equivalence,
        :statistics => :difference_of_means
      }
    end

    def variables=(variables)
      super(variables)

      @equivalence = variables[:equivalence] || (0.8..1.1)
    end

    def test data
      lower, upper = @equivalence.begin, @equivalence.end
      
      _T = []
      rejects = []
      _N = data[0].size + data[1].size
      _S = Math.sqrt(data.pooled_variance)

      _T << Math.sqrt(_N/4) * ((data[0].mean - data[1].mean - lower)/(_S))
      rejects << (_T[0] >= StudentT.quantile(1-@alpha, _N - 2))

      _T << Math.sqrt(_N/4) * ((data[0].mean - data[1].mean - upper)/(_S))
      rejects << (_T[1] <= StudentT.quantile(@alpha, _N - 2))


      return rejects.all?, _T
    end
  end
end
