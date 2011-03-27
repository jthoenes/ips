module Reporting
  class SeriesObserver
    include Observer

    attr_reader :collect

    def initialize
      @collect = []
      @outputter = SeriesOutputter.new
    end

    def <<(collect_key)
      @collect << collect_key unless @collect.include?(collect_key)
    end

    def notify(result)
      output = collect_output(result)
      @outputter.append result.instruction, output
    end

    def finished
      @outputter.close
    end

    def collect_output(result)
      output = {}
      @collect.each do |request|
        method, args = *request
	if args.first == :means
	  output.merge!(result.send(method, :treatment_mean))
	  output.merge!(result.send(method, :control_mean))
	  output.merge!(result.send(method, :placebo_mean))
	else
          output.merge!(result.send(method, *args))
	end
      end
      output
    end
  end
end
