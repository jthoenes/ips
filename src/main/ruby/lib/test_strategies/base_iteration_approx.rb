module TestStrategy
  class BaseIterationApprox < Base
    include IterationHelper

    def initialize
      super
    end

    # Sample Size procedure according to:
    # Kieser et al. Approximate sample sizes for testing hypothesis about the
    # ratio and difference of two means. Journal of Biopharmaceutical Statistics.
    # 9(4), 641-650 (1999)
    def sample_size vars={}
      alpha = alpha(vars)
      beta = beta(vars)

      @logger.debug{"SS: alpha=#{alpha}, beta=#{beta}"}
  
      sample_sizes = []
      factor(vars).to_a.each_with_index do |factor, i|
        sample_sizes << gauss_t_distribution_iteration(2, alpha, beta, factor)
      end
      @logger.debug{"SS: N=max(#{sample_sizes.join ',' })"}
      sample_sizes.max
    end

    private
    # Standart implementations
    def alpha(vars)
      vars[:alpha] || @alpha
    end

    def beta(vars)
      vars[:beta] || @beta
    end


  end
end
