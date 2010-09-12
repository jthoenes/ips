module Reporting
  class SeriesResult
    REQUIRE_REJECTS = [:alpha, :power, :beta, :runs, :count,
      :reject_count, :non_reject_coun].freeze

    SUMMARY_METHODS = [:mean, :median,
      :quartile, :quartiles,
      :quantile, :quantiles]
    
    class << self;
      def requirements method, args
        if REQUIRE_REJECTS.include? method
          [:rejected]
        elsif SUMMARY_METHODS.include? method
          [args.first.to_sym]
        else
          []
        end
      end

      def check_call method, args
        instance_methods.include?(method.to_s)
      end
    end

  end
end
