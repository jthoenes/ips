module DSLProxy
  module Handler
    class NumericHandler < Base

      # Patterns for magic behaviour
      NUMBER_NAMES = {
        'one' => 1, 'two' => 2, 'three' => 3, 'four' => 4,
        'five' => 5, 'six' => 6, 'seven' => 7,
        'eight' => 8, 'nine' => 9
      }.freeze
      NUMBER_METHOD_START = /^(#{NUMBER_NAMES.keys.join('|')})_/.freeze
      # Adds and substracts
      ADD_METHOD_START = /add_to_/.freeze
      SUBSTACT_METHOD_START = /substract_from_/.freeze

      # Method Start
      METHOD_START_ADDS = /^(#{ADD_METHOD_START}|#{SUBSTACT_METHOD_START})/
      METHOD_START_ESCAPE = /^(#{ADD_METHOD_START}|#{SUBSTACT_METHOD_START}|#{NUMBER_METHOD_START})/



      def handable?(method_name)
        work_name = method_name.to_s.gsub(METHOD_START_ESCAPE,'').to_sym
        @method_name == work_name
      end

      private
      def handle_submit method_name, args
        args = args.only if args.size == 1 and args.only.is_a?(Enumerable)
        if method_name.to_s =~ NUMBER_METHOD_START
          @variables[@method_name] = NUMBER_NAMES[$1]
        elsif method_name.to_s =~ /^#{ADD_METHOD_START}/
          @adds[@method_name] = args.embedd
        elsif method_name.to_s =~ /^#{SUBSTACT_METHOD_START}/
          @adds[@method_name] = args.embedd.inverse
        else
          @variables[@method_name] = args.embedd
        end
      end

      def check_constraints(method_name, args)
        args = args.only if args.size == 1 and args.only.is_a?(Enumerable)
        method_name = method_name.to_s
        raise_message('no_numeric') unless args.all?{|a| a.is_a? Numeric}
        raise_message('no_argument') if args.empty? and method_name !~ NUMBER_METHOD_START
        raise_message('double_set') if method_name !~ METHOD_START_ADDS and @variables[@method_name].not_nil?
        raise_message('double_add_set') if method_name =~ METHOD_START_ADDS and @adds[@method_name].not_nil?
      end


    end
  end
end
