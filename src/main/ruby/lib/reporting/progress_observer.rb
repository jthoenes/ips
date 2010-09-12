module Reporting
  class ProgressObserver
    include Observer

    def initialize final
      @final = final
      @count = 0
      start_output_thread
    end

    def notify *args
      @count +=1
    end

    private
    def start_output_thread
      @last = 0.0
      Thread.new do
        loop do
          sleep 2*60
          @percent = @count.to_f/@final
          if @percent - @last > 0.005
            puts "#{DateTime.now.to_s}: #@count of #@final (#@percent)"
            @last = @percent
          end
        end
      end
    end
  end
end
