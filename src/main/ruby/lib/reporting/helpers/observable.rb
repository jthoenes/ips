module Reporting
  module Observable
    def add_observer(observer)
      @__observers__ ||= []
      @__observers__ << observer
    end

    def notify_observers *args
      @__observers__ ||= []
      @__mutex__ ||= Mutex.new
      @__mutex__.synchronize do
        @__observers__.each {|o| o.notify(*args)}
      end
    end

    def notify_finished
      @__observers__ ||= []
      @__mutex__ ||= Mutex.new
      @__mutex__.synchronize do
        @__observers__.each {|o| o.finished}
      end
    end
  end
end
