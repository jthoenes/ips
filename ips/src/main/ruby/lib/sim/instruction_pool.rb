module Sim
  class InstructionPool
    include Reporting::Observable
    
    attr_accessor :collect_raw_data
    attr_accessor :instructions

    def initialize
      @instructions = []
      @instructions << Series.new(self)
      @single_observer = []
      @series_observer = []

      @config = Config.instance
    end

    def send_each(symbol, *args)
      @instructions.each {|i| i.send(symbol, *args)}
    end

    def process
      @series_observer.each do |series_obs|
        add_observer(series_obs)
        @single_observer.each do |single_obs|
          single_obs.add_observer(series_obs) if single_obs.respond_to?(:add_observer)
        end
      end

      @instructions.each_with_index do |instruction, index|
        instruction.index = index+1
        @single_observer.each do |single_obs|
          instruction.add_observer(single_obs.dup)
        end

        instruction.prepare
      end
      @instructions.each_index do |i|
        @instructions[i].process
        @instructions[i] = nil
      end

      notify_finished
    end

    # Shadow Array Methods to @instructions
    def self.shadow *names
      names.each do |name|
        define_method(name) { |*args| @instructions.send(name, *args)}
      end
    end

    # Simply populate a method call to all instructions
    def self.populate *names
      names.each do |name|
        define_method(name) { |*args|  @instructions.each {|i| i.send(name, *args)}}
      end
    end

    # Populate one-argument method calls with mutation functionality
    def self.populate_mutate *names
      names.each do |name|
        define_method(name) do |arg|
          if arg.is_a?(Array)
            new_instructions = []
            @instructions.each do |instr|
              arg.each do |subarg|
                new_instr = instr.extended_clone
                new_instr.name_append subarg.to_s
                new_instr.send(name, subarg)
                new_instructions << new_instr
              end
            end
            @instructions = new_instructions
          else
            @instructions.each {|i| i.send(name, arg)}
          end
        end
      end
    end


    shadow :first, :last, :[], :size
    def map &block
      @instructions.map(&block)
    end

    def each &block
      @instructions.each(&block)
    end


    populate :prepare

    populate_mutate :arms=
    populate_mutate :test_variables=, :sample_size_variables=
    populate_mutate :test_adds=, :sample_size_adds=
    populate_mutate :add_profiler


    attr_accessor :strategy
    attr_reader :series_observer, :single_observer
  end
end
