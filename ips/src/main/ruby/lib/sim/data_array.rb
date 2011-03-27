module Sim
  include_class 'de.bergischweb.simulation.stat.DataArrayJava'
  class RunData < Java::DeBergischwebSimulationStat::DataArrayJava
    include Memoization
    
    attr_reader :recalculation_info

    def initialize arms
      super()
      @sets = []
      arms.each_with_index do |arm, i|
        data = ArmData.new(self, arm)
        @sets << data
      end
      @cache = {}
    end

    def << (samples)
      add_samples(samples)
      clear_cache
    end
    
    def add_recalculation_info (index, variables)
      @recalculation_info ||= []
      @recalculation_info[index] = variables
    end

    # Quantities
    # Helper Method for Stoch. Quantities over arms
    memoize :mean do
      mean_java
    end

    memoize :variance do
      variance_java
    end

    memoize :std do
      Math.sqrt(variance)
    end
    alias :standart_deviation :std

    memoize :adjusted_variance do |delta|
      variance - (sample_size/(4.0*(sample_size - 1.0)))* delta
    end

    memoize :adjusted_std do |delta|
      Math.sqrt(adjusted_variance(delta))
    end
    alias :adjusted_standart_deviation :adjusted_std

    memoize :median do
      median_java
    end

    memoize :pooled_variance do
      numerator = @sets.sum{|data| data.var()*(data.size-1)}
      denominator = size - @sets.size
      numerator/denominator
    end

    memoize :pooled_std do
      Math.sqrt(pooled_variance)
    end
    alias :pooled_standart_deviation :pooled_std


    memoize :delta do
      raise "Delta is only defined for two sets" unless @sets.size == 2
      @sets.first.mean - @sets.last.mean
    end

    memoize :ratio do
      raise "Ratio is only defined for two sets" unless @sets.size == 2
      @sets.first.mean/@sets.last.mean
    end

    # Sample Size Infos
    alias :sample_size :size

    memoize :sample_sizes do
      sample_sizes = []
      @sets.each do |s|
        s.subsample_sizes.each_with_index do |size, index|
          sample_sizes[index] ||= 0
          sample_sizes[index] += size
        end
      end
      sample_sizes
    end


    #
    def to_a
      @sets
    end
    
    def to_ary
      @sets
    end
    
    
    ## Shadow Array Methods
    def [](index)
      @sets[index]
    end

    def not_empty?
      @sets.not_empty?
    end
    
    def each &block
      @sets.each(&block)
    end
    
    def each_index &block
      @sets.each_index(&block)
    end
    
    def each_with_index &block
      @sets.each_with_index(&block)
    end

    def inject *args, &block
      @sets.inject(*args, &block)
    end
  end
end
