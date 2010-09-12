module TestStrategy
  class VariablesStruct
    include Distribution

    def initialize variables = {}
      set_variables(variables)
    end
  
    def fork(variables)
      fork = clone
      fork.set_variables(variables)
      fork
    end
  
    def call_in_context *args, &block
      self.instance_exec(*args, &block)
    end

    def set_variables variables
      variables.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end
  end
end
