# To change this template, choose Tools | Templates
# and open the template in the editor.

module DSLProxy
  module Handler
    class BooleanHandler < Base

      METHOD_START_NEGATIVE = /^(un|not_|in)/.freeze

      def handable?(method_name)
        work_name =  method_name.to_s.gsub(METHOD_START_NEGATIVE,'').to_sym
        @method_name == work_name
      end

      private
      def handle_submit method_name, args
        if args.empty?
          @variables[@method_name] = (method_name.to_s !~ METHOD_START_NEGATIVE)
        else
          @variables[@method_name] = args.embedd
        end
      end

      def check_constraints method_name, args
        raise_message 'no_boolean' unless args.all?{|a| a.bool?}
        raise_message 'to_many' unless args.size <= 2
        raise_message 'no_mutation' if args.size == 2 and args.first == args.last
      end
    end
  end
end
