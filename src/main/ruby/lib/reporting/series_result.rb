module Reporting
  include_class 'de.bergischweb.simulation.stat.SeriesResultJava'
  class SeriesResult < Java::DeBergischwebSimulationStat::SeriesResultJava
    include Sim

    attr_reader :instruction

    def initialize(instruction)
      super()
      @instruction = instruction
    end

    def << hash
      hash.each do |key, value|
        if value.bool?
          add_boolean(key,value)
        elsif value.is_a?(Numeric)
          add_double(key,value)
        else
          raise "Unsupported type"
        end
      end
    end


    def alpha
      {:alpha => __reject_count__.to_f/__count__}
    end

    def power
      {:power => __reject_count__.to_f/__count__}
    end

    def beta
      {:beta => __non_reject_count__.to_f/__count__}
    end

    def runs
      {:runs => __count__}
    end

    def count
      {:count => __count__}
    end

    def reject_count
      {:reject_count => __reject_count__}
    end

    def non_reject_count
      {:non_reject_count => __non_reject_count__}
    end

    # summary methods
    def quantile quantity, at
      quantiles = {}
      at.each do |p|
        quantiles["#{quantity}_quantile_#{p}".to_sym] = calculate_quantile(quantity, p)
      end
      quantiles
    end
    alias :quantiles :quantile

    def median quantity
      {"#{quantity}_median".to_sym => calculate_quantile(quantity, 0.5)}
    end

    def quartile quantity
      quantile(quantity, [0.25, 0.5, 0.75])
    end
    alias :quartiles :quartile

    def mean quantity
      {"#{quantity}_mean".to_sym => calculate_mean(quantity)}
    end

    private
    def __count__
      @count ||= Config.instance.runs
    end

    def __reject_count__
      @reject_count ||= calculate_booleans(:rejected, true)
    end

    def __non_reject_count__
      @non_reject_count ||= calculate_booleans(:rejected, false)
    end
  end
end
