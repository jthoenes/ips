module DSLProxy
  class Arms < Base
    extend MultipleParameters

    def before_call
      @arms = {}
    end

    def order(*args)
      if args.size == 1 and args.only.is_a?(Enumerable)
        @order = args.only.to_a
      else
        @order = args
      end
    end

    def after_call
      set_defaults
      insert_arms @instructions
    end

    protected
    def method_missing method, *args
      add_arm(method, *args)
    end

    private
    def set_defaults
      if @arms.empty?
        add_arm :treatment
        add_arm :control
      elsif @arms.size == 1
        raise "Only one arm specified"
      end
      @order ||= [:treatment, :control, :placebo]
    end

    def insert_arms(instr)
      real_order = @order.select{|name| @arms.keys.include?(name) }
      real_order << @arms.keys
      real_order.flatten!
      real_order.uniq!

      ordered_arms = []
      real_order.each { |name| ordered_arms << @arms[name] }
      ordered_arms.enable_multiple_parameters!
      instr.arms = ordered_arms.mutated(:linear)
    end

    def add_arm name, sampler=RNG::Gauss.new(0,1), weight=1
      @arms[name] = create_arm(name,sampler,weight)
    end

    def create_arm name, sampler, weight
      Sim::Arm.new(name, sampler, weight)
    end
    mutate_params :create_arm, :linear
  end
end
