module Sim
  include_class 'de.bergischweb.simulation.stat.DataJava'
  class ArmData < Java::DeBergischwebSimulationStat::DataJava
    include Memoization
    attr_reader :arm

    def initialize parent, arm=:dummy
      super()
      @parent = parent
      @arm = arm
    end

    def name
      @name ||= (@arm.is_a?(Sim::Arm)) ? @arm.name : @arm
    end

    # Array simulator
    def << samples
      add_samples(samples)
      @parent << samples
      clear_cache
    end

    ## Some Convinience
    memoize :mean do
      mean_java
    end

    memoize :variance do
      variance_java
    end

    memoize :median do
      median_java
    end

    memoize :samples do
      samples_java
    end

    memoize :subsamples do
      subsamples_java
    end

    memoize :subsample_sizes do
      subsamples.map(&:size).map(&:to_f)
    end

    memoize :to_a do
      self.samples.to_a
    end
    
    alias :sample_size :size
    alias :var :variance
  end
end
