module Sim
  class Config
    include Singleton

    attr_accessor :runs, :dsl_file

    def initialize
      @dsl_file = 'simulation.rb'
    end

    def dsl_file=(dsl_file)
      @dsl_file = File.basename(dsl_file)
    end

    def run_pools
      processors = Java::JavaLang::Runtime.getRuntime().availableProcessors()
      step = @runs/processors
      run_pools = [step]*(processors-1)
      run_pools << @runs - run_pools.sum

      run_pools
    end


    private
    def reporting_config
      @reporting_config ||= Reporting::Config.instance
    end


  end
end
