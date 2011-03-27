module RNG
  # Gaussian random number generator.
  #
  # Objects of this class generate random numbers gaussian/normal distributed
  # with the defined +mean+ and the defined +variance+.
  #
  class Gauss


    # Property +mean+ for the expected value of the generated numbers.
    attr_reader :mean
    
    # Property +standard_devariation+ for the standard devariation of the generated numbers.
    attr_reader :standard_devariation
    
    # Property +variance+ for the squared variance/standart devariation of 
    # the generated numbers.
    attr_reader :variance

    # Alias +mu+ for the +mean+ method.
    alias :mu :mean

    # Alias +std+ for the +standard_devariation+ method.
    alias :std :standard_devariation

    # Alias +var+ for the +variance+ method.
    alias :var :variance

    # Creates a new gaussian random number generator object with defined
    # +mean+ and +variance+.
    #
    # * mean     - The expectation value of the random numbers. Defaults to 0.0
    # * variance - The squared standard devariation of the random numbers. Defaults to 1.0
    #
    def initialize mean=nil, variance=nil
      mean ||= 0.0
      variance ||= 0.0

      # Assingning the float value of the arguments to the properties.
      @mean, @variance = mean.to_f, variance.to_f

      # Saving the standart devariation
      @std = Math.sqrt(@variance)

      # Initialising the Value Server of the Java-Side for doing the work
      @rng = Java::DeBergischwebSimulationRNG::GaussianValueServer.new
      @rng.mu = @mean
      @rng.sigma = @std
    end


    # Generate +n+ gaussian distributed random variables with mean +mean+ and
    # variance +variance+. I returns an array of java doubles - NOT Ruby floats.
    #
    # * n - The count of random variables to be generated.
    #
    def sample n=1
      @rng.fill(n)
    end

    #
    # Defines equality for this class. Two objects are equal, if there are both
    # gaussian random value generators and have the same +mean+ and +variance+.
    # Returns +true+ if both are equal.
    #
    # * other - The object to compare with.
    #
    def eql?(other)
      if ! other.is_a?(self.class)
        false
      else
        [@mean, @variance] == [other.mean, other.variance]
      end
    end
    alias :== :eql?

    #  Returns the parameters to be included into the result file to represent
    #  the selected random value generator.
    #
    def parameters
      {
        :distribution => 'gauss',
        :mean => @mean,
        :variance => @variance
      }
    end
  end
end
