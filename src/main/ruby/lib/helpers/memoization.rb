# This module provides a memorize class method, you could use to 
# methorize a methods result. 
#
# Usage example:
#
#    memoize :my_method_name do |n,m|
#      some_ver_complex_calulation_using(n).and(m)
#    end
#
# Or:
#   
#   def my_method_name n,m
#     some_ver_complex_calulation_using(n).and(m)
#   end
#   memoize :my_method_name
# 
module Memoization
  # Clears the complete memoization cache. By default, it clears
  # the whole cache. You can however pass a method name symbols as 
  # parameters, to only clear the cache of those methods
  def clear_cache *args
    if args.empty?
      @__cache__ = {}
    else
      args.each {|method_name| @__cache__[method_name] = {}}
    end
  end

  
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def memoize *args, &block
      if block.not_nil?
        create_memoized_method(args.first, &block)
      else
        memoize_methods(*methods)
      end
    end
    
    def memoize_methods *methods
      methods.each { |method_name| memoize_method(method_name) }
    end
    
    private
    def memoize_method method_name
      original_method = instance_method(method_name)

      define_method(method_name) do |*args|
        @__cache__ ||= {}
        @__cache__[method_name] ||={}
        if @__cache__[method_name][args].nil?
          bound_method = original_method.bind(self)
          @__cache__[method_name][args] = bound_method.call(*args)
        end
        @__cache__[method_name][args]
      end
    end

    def create_memoized_method method_name, &block
      define_method(method_name) do |*args|
        @__cache__ ||= {}
        @__cache__[method_name] ||={}
        if @__cache__[method_name][args].nil?
          @__cache__[method_name][args] = instance_exec(*args, &block)
        end
        @__cache__[method_name][args]
      end
    end
  end

end
