module TestStrategy
  module ExtractHelper
    def extract_alpha(variables)
      @alpha = variables[:alpha] || 0.05
      assert_probability(@alpha)
    end

    def extract_beta(variables)
      @beta = variables[:beta]
      @beta ||= (variables[:power].not_nil?) ? 1.0 - variables[:power] :  0.2
      assert_probability(@beta)
    end

    def extract_sided(variables)
      @sided = variables[:sided] || 2
      
      assert {@sided == 1 || @sided == 2}
    end

    def extract_delta(variables)
      @delta = variables[:delta] || @arms[0].mean - @arms[1].mean
    end

    def extract_variance(variables)
      @variance = variables[:variance] || @arms[0].variance
    end
  end
end
