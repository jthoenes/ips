module TestStrategy
  module Approx
    module HypothesisDOM
      def factor vars = {}
        delta = vars[:delta] || @delta
        variance = vars[:variance] || @variance
        _B(vars).map{|b| (2 * variance)/((delta - b)**2) }
      end
    end
  end
end
