module Reporting
  class SingleResult

    class << self
       def check_call method, args
        instance_methods.include?(method.to_s)
      end
    end

    def self.shadow *methods
      methods.each do |method|
        define_method(method) do
          {method => @data.send(method)}
        end
      end
    end

    def self.shadow_arms method_hash = {}
      method_hash.each do |method, name|
        define_method(method) do
          ret = {}
          @data.each do |arm|
            ret["#{arm.name}_#{name}".to_sym] = arm.send(name)
          end
          ret
        end
      end
    end


    def initialize instruction, rejected, statistics, data
      @instruction = instruction
      @rejected, @statistics, @data = rejected, statistics, data
    end

    attr_reader :instruction
    shadow :mean, :delta, :median, :sample_size
    shadow :variance, :std, :standart_deviation
    shadow :pooled_variance, :pooled_std, :pooled_standart_deviation
    shadow_arms :means => :mean, :variances => :variance, :medians => :median

    def rejected
      {:rejected => @rejected}
    end

    def statistics
      {:statistics => @statistics}
    end
    
    def recalculation_input
      info = {}
      @data.recalculation_info.each_with_index do |adj_info, i|
        adj_info.each do |key, value|
          info["recalculation_#{key}_#{i+1}"] = value
        end
      end
      info
    end

    def sample_sizes
      sample_sizes = {}
      @data.sample_sizes.each_with_index do |size, i|
        sample_sizes["sample_size_#{i+1}"] = size
      end
      sample_sizes 
    end
  end
end
