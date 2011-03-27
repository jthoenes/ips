module Distribution
  class StudentT < Base
    include_class 'org.apache.commons.math.distribution.TDistributionImpl'

    attr_reader :df
    alias :degree_of_freedom :df

    def StudentT.get *args
      @object_cache ||= {}
      @object_cache[args] ||= new(*args)
    end
    
    def StudentT.quantile(p, df)
      get(df).quantile(p)
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
    
    def eql?(other)
      if other === self
        true
      else
        other.class == self.class && other.df == self.df
      end
    end
    
    def to_s
      "t_{#{@df}}"
    end
    
    def collect_keys
      [:distribution, :mean, :variance]
    end

    private
    def initialize df
      assert {df > 0}
      @df = df.to_int

      @quantile_cache, @pdf_cache, @cdf_cache = {}, {},{}
      init_commons_math
    end

    def init_commons_math
      @distr = Java::OrgApacheCommonsMathDistribution::TDistributionImpl.new(@df)
    end
  end
end
