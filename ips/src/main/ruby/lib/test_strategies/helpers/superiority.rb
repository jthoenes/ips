module TestStrategy
  module Approx
    module Superiority
      private
      def alpha vars
        sided = vars[:sided] || @sided
        alpha = vars[:alpha] || @alpha
        if sided == 2
          (alpha)/2.0
        elsif sided == 1
          alpha
        else
          raise "fail"
        end
      end
      
      def _B vars
        [0]
      end

    end
  end
end
