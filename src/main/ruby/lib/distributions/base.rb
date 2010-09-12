module Distribution
  class Base
    def r
      @r ||= RSRuby.instance
    end

    def initialize
      @logger = self.class.logger
    end

    def Base.logger
      Logger['distributions']
    end
  end
end
