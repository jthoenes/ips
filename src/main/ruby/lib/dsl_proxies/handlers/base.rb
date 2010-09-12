module DSLProxy
  module Handler
    class Base
      attr_reader :variables, :adds

      HANDLER_METHOD = /[A-Za-z][a-z0-9]+/

      def self.handle_extend(symbol, hash={}, args=[])
        symbol_s = symbol.to_s
        if args.empty?
          if symbol_s.to_s =~ /#{NumericHandler::NUMBER_METHOD_START}#{HANDLER_METHOD}$/
            symbol = symbol_s.gsub(NumericHandler::NUMBER_METHOD_START, '').to_sym
            return append_numeric_handler(symbol, hash)
          elsif (symbol_s =~ /#{BooleanHandler::METHOD_START_NEGATIVE}#{HANDLER_METHOD}$/ or
                symbol_s =~/^#{HANDLER_METHOD}$/)
            symbol = symbol_s.gsub(BooleanHandler::METHOD_START_NEGATIVE, '').to_sym
            return append_boolean_handler(symbol, hash)
          end
        elsif (args.all? { |a| a.is_a? Numeric } and
              (symbol_s =~ /^#{HANDLER_METHOD}$/ or
                symbol_s =~ /#{NumericHandler::METHOD_START_ADDS}#{HANDLER_METHOD}$/))
          symbol = symbol_s.gsub(NumericHandler::METHOD_START_ADDS, '').to_sym
          return append_numeric_handler(symbol, hash)
        elsif (args.all? { |a| a.bool? } and
              symbol_s =~/^#{HANDLER_METHOD}$/)
          return append_boolean_handler(symbol, hash)
        end
        return false
      end



      def self.append_numeric_handler(symbol, hash)
        return symbol, NumericHandler.new(symbol, hash)
      end

      def self.append_boolean_handler(symbol, hash)
        return symbol, BooleanHandler.new(symbol, hash)
      end


      def initialize method_name, hash = {}
        raise "Unsupported Symbol" unless method_name.to_s =~ /^#{HANDLER_METHOD}$/
        @method_name = method_name
        @variables = hash[:variables] || {}
        @adds = hash[:adds] || {}
      end

      def handable?(method_name)
        raise "NOT_YET_IMPLEMENTED"
      end

      def handle(method_name, *args)
        raise "Cannot handle this call" unless handable?(method_name)
        check_constraints(method_name, args)
        handle_submit(method_name, args)
      end

      protected
      def raise_message message_id
        handler_name = self.class.name.
          gsub('Handler', '').gsub('DSLProxy', '').gsub(':', '').downcase
        raise I18n.t("error.#{handler_name}.#{message_id}", :value => @method_name.to_s )
      end
    end
  end
end
