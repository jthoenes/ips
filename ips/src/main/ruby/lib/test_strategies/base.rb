module TestStrategy
	class Base
    include Distribution
    include ExtractHelper

    attr_accessor :arms
    attr_accessor :test_proc, :sample_size_proc
		
		@@strategies = [SuperiorityDOM,
      NonInferiorityDOM,
      EquivalenceDOM,
      PigeotEtAl,
      None
    ]
    def initialize
      @logger = self.class.logger
    end

    def Base.logger
      Logger['test_strategy']
    end

		def Base.select properties
			strategy = @@strategies.select{|s| s.match(properties)}
      raise "More than one strategy found" if strategy.size > 1
      return (strategy.not_empty?) ? strategy.only.new : nil
		end

    def variables=(variables)
      @variables_struct = VariablesStruct.new(variables)

      extract_alpha(variables)
      extract_beta(variables)

      @fixed = variables[:fixed]
      @initial = variables[:initial]
    end

    def adds=(adds)
      adds.each do |key, add|
        if value = instance_variable_get("@#{key}")
          instance_variable_set("@#{key}", value + add)
        end
      end
    end

    def initial_sample_size
      if @fixed
        @fixed
      elsif @initial
        @initial
      elsif @sample_size_proc
        @variables_struct.call_in_context(&@sample_size_proc)
      else
        sample_size({})
      end
    end

    def adjusted_sample_size variables
      if @fixed
        @fixed
      elsif @sample_size_proc
        adj_variables_struct = @variables_struct.fork(variables)
        adj_variables_struct.call_in_context(&@sample_size_proc)
      else
        sample_size(variables)
      end
    end

    def perform_test(data)
      if @test_proc
        @variables_struct.call_in_context(data, *data, &@test_proc)
      else
        test(data)
      end
    end


    protected
    def Base.match properties
      properties.each do |key, value|
        return false if self.properties[key] != value
      end
      return true
    end
  end
end