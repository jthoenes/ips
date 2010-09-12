module DSLProxy
  class InternalPilot < Base
    include VariablesHelper

    handle_boolean :blinded
    handle_boolean :restricted
    handle_boolean :control
    handle_numeric :at
    
    def before_call
      @adjuster = {}
    end

    def process_variables variables
      return unless called?

      check_constraints(variables)

      profiler = []
      variables.each {|arg| profiler << Sim::Adjuster.new(@adjuster.clone, arg)}
      profiler << Sim::ControllAdjuster.new if variables.first[:control]
      instructions.add_profiler(profiler)
    end

    def adjust *args, &block
      if block_given?
        raise I18n.error("error.internal_profile_custom_adjust_multiple") unless args.size == 1
        @adjuster[args.only] = block
      else
        args.each {|q| @adjuster[q] = nil}
      end
    end

    private
    def check_constraints(variables)
      raise I18n.t("error.internal_profile_with_fixed_sample_sizer") if fixed_sample_size?

      variables.each do |var|
        var[:at] ||= 0.5
        raise I18n.t("error.profile_at_non_percentage_float") if var[:at].is_a?(Float) and (var[:at] > 2.0)
        raise I18n.t("error.profile_at_negative_value") if var[:at] < 0
      end
    end

    def fixed_sample_size?
      $proxies.sample_size_proxy.fixed?
    end
  end
end
