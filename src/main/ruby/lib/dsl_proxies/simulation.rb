module DSLProxy
	class Simulation < Base
    include SubproxyHelper
    include VariablesHelper

    handle_numeric :runs

		dsl_subproxy :arms => Arms
    dsl_subproxy :test => Test
    dsl_subproxy :sample_size => SampleSize
    dsl_subproxy :internal_pilot => InternalPilot
    dsl_subproxy :collect => Collect

    def process_variables(variables)
      config = Sim::Config.instance
      config.runs = variables.first[:runs] || 1*10**6
    end

    # FIXME: Remove this regression fix
    alias :internal_profile :internal_pilot
  end
end
