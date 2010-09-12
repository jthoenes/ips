module DSLProxy

  module ArrayMultipleParameters
    def mutated type=:cross
      if type == :cross
        mutate_cross
      elsif type == :linear
        mutate_linear
      end
    end


    private
    def mutate_cross
      common_mutation([[]]) do |ary, val_array|
        ret = []
        ary.each do |subary|
          val_array.each do |val|
            ret << subary.clone + [val]
          end
        end
        ret
      end
    end

    def mutate_linear
      size = 1
      each do |value|
        if value.is_a?(Array)
          size = value.size
        end
      end
      init = []
      size.times {init << []}
      common_mutation(init) do |ret, val_array|
        val_array.each_with_index do |val, index|
          ret[index] << val
        end
        ret
      end
    end

    def common_mutation ret
      each do |value|
        if value.is_a?(Array)
          ret = yield(ret, value)
        else
          ret.each {|hsh| hsh << value}
        end
      end
      ret
    end
  end

  module HashMultipleParameters
    def mutated type=:cross
      if type == :cross
        mutate_cross
      elsif type == :linear
        mutate_linear
      end
    end


    private
    def mutate_cross
      common_mutation([{}]) do |ary, key, val_array|
        ret = []
        ary.each do |hsh|
          val_array.each do |val|
            ret << hsh.clone.merge(key => val)
          end
        end
        ret
      end
    end

    def mutate_linear
      size = 1
      each_value do |value|
        if value.is_a?(Array)
          size = value.size
        end
      end
      init = []
      size.times {init << {}}
      common_mutation(init) do |ret, key, val_array|
        val_array.each_with_index do |val, index|
          ret[index][key] = val
        end
        ret
      end
    end

    def common_mutation ret
      each do |key, value|
        if value.is_a?(Array)
          ret = yield(ret, key, value)
        else
          ret.each {|hsh| hsh[key] = value}
        end
      end
      ret
    end

  end

  
  module MultipleParameters
    def mutate_params(name, type=:cross)
      original_method = instance_method(name)

      define_method(name) do |*args|
        mutated_arguments = args.clone
        mutated_arguments.each_with_index do |hsh, i|
          if hsh.is_a?(Hash)
            hsh.enable_multiple_parameters!
            mutated_arguments[i] = hsh.mutated(type)
          end
        end

        mutated_arguments.enable_multiple_parameters!
        mutated_arguments = mutated_arguments.mutated(type)

        bound_method = original_method.bind(self)
        ret = []
        mutated_arguments.each do |mutated_args|
          ret << bound_method.call(*mutated_args)
        end

        (ret.size == 1) ? ret.only : ret
      end
    end
  end

end

class Array
  def enable_multiple_parameters!
    self.extend(DSLProxy::ArrayMultipleParameters)
  end
end

class Hash
  def enable_multiple_parameters!
    self.extend(DSLProxy::HashMultipleParameters)
  end
end
