module DSLProxy
  module Handler
    class QuantityHandler < Base



      def handable?(method_name)
        method_name.to_s =~ /(^|#{NumericHandler::METHOD_START_ADDS})#{Base::HANDLER_METHOD}_#{@method_name}$/
      end

      private
      def handle_submit method_name, args
        method_name.to_s =~ /^(.*_)?(#{Base::HANDLER_METHOD})_#{@method_name}/
        arm_name = $2.to_sym
        if method_name.to_s =~ /^#{NumericHandler::ADD_METHOD_START}/
          @adds[key_name] ||= {}
          @adds[key_name][arm_name] = args.embedd
        elsif method_name.to_s =~ /^#{NumericHandler::SUBSTACT_METHOD_START}/
          @adds[key_name] ||= {}
          @adds[key_name][arm_name] = args.embedd.inverse
        else
          @variables[key_name] ||= {}
          @variables[key_name][arm_name] = args.embedd
        end
      end

      def key_name
        @key_name ||= "#{@method_name}s".to_sym
      end

      def check_constraints(method_name, args)
        #        raise_message('no_numeric') unless args.all?{|a| a.is_a? Numeric}
        #        raise_message('no_argument') if args.empty? and method_name !~ NUMBER_METHOD_START
        #        raise_message('double_set') if method_name !~ METHOD_START_ADDS and @variables[@method_name].not_nil?
        #        raise_message('double_add_set') if method_name =~ METHOD_START_ADDS and @adds[@method_name].not_nil?
      end


    end
  end
end
