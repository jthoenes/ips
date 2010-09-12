module DSLProxy
  module DistributionHelper
    extend MultipleParameters

    def N mean, variance
      RNG::Gauss.new(mean,variance)
    end

    mutate_params :N
  end
end
