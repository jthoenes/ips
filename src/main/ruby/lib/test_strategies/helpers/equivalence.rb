module TestStrategy
  module Approx
    module Equivalence
      private
      def beta vars
        vars[:delta] ||= vars[:means][0] - vars[:means][1]
        if vars[:delta] == 0
          (vars[:beta] || @beta)/2.0
        else
          vars[:beta] || @beta
        end
      end

      def _B vars
        equi = vars[:equivalence] || @equivalence
        [equi.begin, equi.end]
      end
    end
  end
end
