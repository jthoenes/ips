module DSLProxy
  module Handler
    class RangeHandler < Base
      def handable?(method_name)
        method_name == @method_name
      end

      private
      def handle_submit(method_name, args)
        @variables[method_name] = args.embedd
        @submitted = true
      end

      def check_constraints method_name, args
        raise_message 'no_argument' unless args.size > 0
        raise_message 'no_range' unless args.all?{|a| a.is_a? Range}
        raise_message 'double_set' if @submitted
        raise_message 'not_ascending' unless args.all?{|a| a.begin < a.end }
      end
    end
  end
end
