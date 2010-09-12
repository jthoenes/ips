module DSLProxy
  module VariablesHelper
    # Class methods for override
    module ClassMethods
      
      def handle_symbol name
        @handlers ||= {}
        @handlers[name] = DSLProxy::Handler::SymbolHandler
      end

      def handle_numeric name
        @handlers ||= {}
        @handlers[name] = DSLProxy::Handler::NumericHandler
      end

      def handle_boolean name
        @handlers ||= {}
        @handlers[name] = DSLProxy::Handler::BooleanHandler
      end

      def handle_range name
        @handlers ||= {}
        @handlers[name] = DSLProxy::Handler::RangeHandler
      end

      def handle_quantity name
        @handlers ||= {}
        @handlers[name] = DSLProxy::Handler::QuantityHandler
      end

      def extend_handlers switch=true
        @switch=(switch)
      end

      def handlers
        @handlers || {}
      end

      def extend_handlers?
        @switch || false
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def after_call
      before_variables_call
      @__variables__ ||= {}
      @__variables__.enable_multiple_parameters!
      @__adds__ ||= {}
      @__adds__.enable_multiple_parameters!
      process_variables(@__variables__.mutated)
      process_variables_and_adds(@__variables__.mutated, @__adds__.mutated)
      process_adds(@__adds__.mutated)
      after_variables_call
    end

    # Hook
    def process_variables *args; end
    def process_variables_and_adds *args; end
    def process_adds *args; end
    def before_variables_call; end
    def after_variables_call; end

    #private
    def method_missing symbol, *args
      # throw method missing error if we are frozen
      super if @__frozen__


      __handlers__.each_value do |handler|
        if handler.handable?(symbol)
          handler.handle(symbol, *args)
          return
        end
      end

      if self.class.extend_handlers?
        name, handler = DSLProxy::Handler::Base.handle_extend(symbol, __handler_hash__, args)
        if name
          @__handlers__[name] = handler
          return send(symbol, *args)
        end
      end
      
      super
    end

    def extend_handlers?
      extend_handlers?
    end

    def __handler_hash__
      @__variables__ ||= {}
      @__adds__ ||= {}
      {:variables => @__variables__, :adds => @__adds__}
    end

    def __handlers__
      if @__handlers__.nil?
        @__handlers__ = {}
        self.class.handlers.each do |key, klass|
          @__handlers__[key] = klass.new(key,
            __handler_hash__
          )
        end
      end
      @__handlers__
    end
  end
end
