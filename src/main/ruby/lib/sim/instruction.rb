# This class represents the instruction for running one single simulation
module Sim
  class Series
    include Reporting
    include Observable

    def self.attr_clone_accessor *names
      names.each do |meth|
        attr_reader meth
        define_method("#{meth}=") do |arg|
          instance_variable_set("@#{meth}", arg.clone)
        end
      end
    end

    # Hier bitte nur Clone-Accessors
    attr_reader :name
    attr_accessor :strategy, :collector, :index
    attr_accessor :profilers
    attr_clone_accessor :test_variables, :sample_size_variables
    attr_clone_accessor :test_adds, :sample_size_adds
    attr_accessor :arms

    def initialize pool
      @arms = []
      @arm_names = {}
      @pool = pool

      @profilers = []
      @name = ""

      @test_variables = {}
      @test_adds = {}
      @sample_size_variables = {}
      @sample_size_adds = {}

      @config = Config.instance
    end

    def name_append (app)
      @name += " #{app}"
      @name.strip!
    end


    def add_arm arm
      @arms << arm
      index = @arms.rindex(arm)
      @arm_names[arm.name] = index
    end

    def add_profiler profiler
      @profilers << profiler
    end

    def extended_clone
      nobj = clone
      nobj.arms = @arms.clone
      nobj.profilers = @profilers.clone
      nobj.test_variables = @test_variables.clone
      nobj.test_adds = @test_adds.clone
      nobj.sample_size_variables = @sample_size_variables.clone
      nobj.sample_size_adds = @sample_size_adds.clone
      nobj
    end

    def prepare
      total_weight = @arms.inject(0){|sum, arm| arm.weight + sum}
      @arms.each {|a| a.calculate_percentage(total_weight)}

      @strategy = @pool.strategy.dup
      @strategy.arms = @arms
      @strategy.variables = @test_variables.merge(@sample_size_variables)
      @strategy.adds = @test_adds.merge(@sample_size_adds)
    end

    def process
      threads = []
      @config.run_pools.each do |size|
        t = Thread.new { size.times {process_one} }
        t.priority = -1
        threads << t
      end
      threads.each(&:join)
      notify_finished
    end

    def process_one
      data = RunData.new(@arms)
      
      sample_sizes = []
      sample_sizes << @strategy.initial_sample_size
      @profilers.first.divide(sample_sizes) unless @profilers.first.nil?
      
      sample_sizes.each_with_index do |count, i|
        @arms.each_with_index do |arm, index|
          data[index] << arm.sample_part_of(count)
        end
        unless @profilers[i].nil?
          variables = @profilers[i].adjust(@strategy, sample_sizes, data)
          data.add_recalculation_info(i, variables)
        end
        @profilers[i+1].divide(sample_sizes) unless @profilers[i+1].nil?
      end

      rejected, statistics = @strategy.perform_test(data)
      notify_observers(SingleResult.new(self, rejected, statistics, data))
    end


    def parameters
      if @parameters.nil?
        @parameters = {:index => @index}
        @test_variables.each {|k,v| @parameters["test_#{k}"] = v}
        @sample_size_variables.each {|k,v| @parameters["planned_#{k}"] = v}
        @arms.each {|a| @parameters.merge!(a.parameters)}
        @profilers.each_with_index {|p, i| @parameters.merge!(p.collect_values(i))}
        @parameters.freeze
      end
      @parameters
    end

  end

  # Diagnosis Methods
  class Series
    def sample_size
      [@strategy.initial_sample_size, @strategy.adjusted_sample_size({})]
    end
  end
end
