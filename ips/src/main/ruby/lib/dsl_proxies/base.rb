module DSLProxy
	class Base
		include DistributionHelper

    attr_reader :instructions
    def initialize(instructions=nil, &block)
      @instructions = instructions || Sim::InstructionPool.new
      @call_stack = block
		end

    def call
      before_call
      call_dsl_block(&@call_stack) unless @call_stack.nil?
      after_call
    end

    # Hook Method
    def before_call; end
    def after_call; end

    def called?
      @has_been_called.not_nil?
    end

    private
    def call_dsl_block &block
      @has_been_called = true
      if block.arity == 1
        block.call(self)
      else
        self.instance_eval(&block)
      end
    end
  end
end