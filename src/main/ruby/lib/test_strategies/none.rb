module TestStrategy
  class None < Base
    def self.properties
      {
        :strategy => :none
      }
    end

  end
end
