module Reporting
  module Observer

    def notify *args
      raise "Please implement"
    end

    def finished; end
  end
end
