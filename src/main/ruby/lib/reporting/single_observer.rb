module Reporting
  class SingleObserver
    include Observer

    def initialize()
      @collect = []
    end

    def <<(collect_key)
      @collect << collect_key unless @collect.include?(collect_key)
    end

    def empty?
      @collect.empty?
    end

    def notify single_result
      @mutex ||= Mutex.new
      @mutex.synchronize do
        @outputter ||= SingleOutputter.new(single_result.instruction)
        single_result_minimized = {}
        @collect.each {|q| single_result_minimized.merge!(single_result.send(q))}
        @outputter.append single_result_minimized
      end
    end

    def finished
      @outputter.close
    end
  end
end
