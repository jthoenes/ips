module Sim
  class Arm
    attr_reader :name, :sampler, :weight
    attr_reader :percentage

    def initialize name, sampler, weight
      @name = name
      @sampler = sampler
      @sampler.freeze
      @weight = weight
      @weight.freeze
    end

    def calculate_percentage total
      @percentage = weight.to_f / total.to_f
      @percentage.freeze
    end

    def sample_part_of total
      count = (total.to_f * @percentage).ceil
      sampler.sample(count)
    end

    def to_s
      "#{@name}=#{@sampler.to_s},#{@weight}"
    end

    def parameters
      parameters = {}
      sampler.parameters.each {|k, v| parameters["#{@name}_#{k}".to_sym] = v}
      parameters["#{@name}_weight".to_sym] = @weight

      parameters
    end

    def mean
      @sampler.mean
    end

    def  variance
      @sampler.variance
    end

  end
end
