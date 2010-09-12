module Distribution
  class Gauss < Base
    include_class 'org.apache.commons.math.distribution.NormalDistributionImpl'

    attr_reader :mean, :variance
    alias :mu :mean
    alias :var :variance
    
    def Gauss.get *args
      @object_cache ||= {}
      @object_cache[args] ||= new(*args)
    end
    
    def Gauss.quantile p
      get().quantile(p)
    end

    def quantile p
      @quantile_cache[p] ||= @distr.inverse_cumulative_probability(p)
    end
    alias :icdf :quantile

    #def pdf x
    #  @pdf_cache[x] ||=
    #end

    def cdf x
      @cdf_cache[x] ||= @distr.cumulative_propability(x)
    end

    def standart_deviation
      @std
    end
    alias :sigma :standart_deviation
    alias :std :standart_deviation

    def eql?(other)
      if other === self
        true
      else
        other.class == self.class && other.mean == self.mean && other.variance == self.variance
      end
    end

    def to_s
      "N(#{@mean}, #{@variance})"
    end
    
    def collect_keys
      [:distribution, :mean, :variance]
    end

    private
    def initialize mean=0.0, variance=1.0
      super()
      raise "The variance needs to be positive" unless variance > 0
      @mean, @variance = mean.to_f, variance.to_f
      @std = Math.sqrt(@variance)

      @quantile_cache, @pdf_cache, @cdf_cache = {}, {}, {}
      init_commons_math
    end


    def init_commons_math
      @distr = Java::OrgApacheCommonsMathDistribution::NormalDistributionImpl.new(@mean, @std)
    end
  end

end
