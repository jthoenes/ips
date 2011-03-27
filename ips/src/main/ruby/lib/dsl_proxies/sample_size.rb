module DSLProxy
  class SampleSize < Base
    include VariablesHelper

    # TODO Typische Werte vordefinieren???
    extend_handlers

    def process_variables_and_adds(variables, adds)
      check_constraints(variables)

      @instructions.strategy.sample_size_proc = @method unless @method.nil?

      @instructions.sample_size_variables = variables
      @instructions.sample_size_adds = adds

      # Saving status for internal profile check
      @is_fixed = variables.any?{|v| v[:fixed].not_nil? }
    end

    def method &block
      @method = block
    end

    def fixed?
      @is_fixed
    end
   
    private
    def check_constraints(variables)
      variables = variables.first # as we check only symbols, we can do with the first representation
      raise I18n.t "error.override_fixed_sample_size" if @method.not_nil? and variables[:fixed].not_nil?
      raise I18n.t "error.fixed_and_initial_sample_size" if variables[:fixed].not_nil? and variables[:initial].not_nil?
    end
  end
end
