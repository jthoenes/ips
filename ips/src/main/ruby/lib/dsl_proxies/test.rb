module DSLProxy
	class Test < Base
		include VariablesHelper

    handle_symbol :distribution
    handle_symbol :hypothesis
    handle_symbol :statistics
    handle_symbol :strategy

    # TODO Typische Werte vordefinieren???
    extend_handlers
    

    def process_variables_and_adds(variables, adds)

      selection = variables.first.select {|key,value|
        [:distribution, :hypothesis, :statistics, :strategy].include?(key)}
      selection = {:strategy => :none} if selection.empty?

      @instructions.strategy = TestStrategy::Base.select(selection)

      @instructions.strategy.test_proc = @method unless @method.nil?

      @instructions.test_variables = variables
      @instructions.test_adds = adds
    end

    ###
    def method &block
      @method = block
    end
  end
end
