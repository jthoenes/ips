module DSLProxy
  module Handler
    class SymbolHandler < Base
      def handable?(method_name)
        method_name == @method_name
      end

      private
      def handle_submit(method_name, args)
        @variables[method_name] = args.only
        @submitted = true
      end

      def check_constraints method_name, args
        raise_message 'no_argument' unless args.size > 0
        raise_message 'multiple_arguments' unless args.size <= 1
        raise_message 'no_symbol' unless args.all?{|a| a.is_a? Symbol}
        raise_message 'double_set' if @submitted
      end
    end
  end
end
