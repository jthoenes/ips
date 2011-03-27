module DSLProxy
  module SubproxyHelper
    module ClassMethods
      # Calling the DSL-Block according to the arity
      def dsl_subproxy hash
        hash.each {|name, klass| add_subproxy(name, klass)}
      end

      def add_subproxy name, klass
        @dsl_subproxy_list ||= []
        @dsl_subproxy_list << name
        define_method("__#{name}__") do |block|
          @dsl_subproxies ||= {}
          @dsl_subproxies[name] = klass.new(@instructions, &block)
        end
        class_eval "def #{name} &block; __#{name}__(block); end"
        # Getter for the proxy
        define_method("#{name}_proxy") do
          @dsl_subproxies ||= {}
          @dsl_subproxies[name] ||= klass.new(@instructions)
        end
      end

      def dsl_subproxy_list
        @dsl_subproxy_list || []
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def call
      before_call
      call_dsl_block(&@call_stack) unless @call_stack.nil?
      before_subproxy_call
      subproxy_call
      after_subproxy_call
      after_call
    end

    # Hook Methods
    def before_subproxy_call; end
    def after_subproxy_call; end

    # Subproxy-Calls
    def subproxy_call
      dsl_subproxy_list.each do |name|
        # Getter creates the proxy implicit
        send("#{name}_proxy").call
      end
    end

    private
    def dsl_subproxy_list
      self.class.dsl_subproxy_list
    end
  end
end
