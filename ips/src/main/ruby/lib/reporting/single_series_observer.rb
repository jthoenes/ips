module Reporting
  class SingleSeriesObserver
    include Observable
    include Observer

    def initialize()
      @collect = []
    end

    def <<(collect_key)
      @collect << collect_key unless @collect.include?(collect_key)
    end

    def notify single_result
      @result ||= SeriesResult.new(single_result.instruction)
      single_result_minimized = {}
      @collect.each {|q| single_result_minimized.merge!(single_result.send(q))}
      @result << single_result_minimized
    end

    def finished
      notify_observers(@result)
    end
  end
end
