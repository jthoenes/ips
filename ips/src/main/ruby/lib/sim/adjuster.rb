module Sim
  class ControllAdjuster
    attr_reader :at, :restricted, :blinded, :adjust_procs

    def divide sample_sizes
      sample_sizes + [0]
    end

    def adjust sample_sizer, sample_sizes, data
      sample_sizes
    end

    def to_s
      "internal pilot: control"
    end

    def collect_keys index
      index +=1
      ["profiler#{index}_at".to_sym,
        "profiler#{index}_restricted".to_sym,
        "profiler#{index}_blinded".to_sym ]
    end

    def collect_values index
      index +=1
      {"profiler#{index}_at".to_sym => 'control',
        "profiler#{index}_restricted".to_sym => 'control',
        "profiler#{index}_blinded".to_sym => 'control'}
    end
  end

  class Adjuster

    attr_reader :at, :restricted, :blinded, :adjust_procs

    def initialize adjust_procs={}, vars = {}
      @at = vars[:at] || 0.5
      @restricted = vars[:restricted] || false
      @blinded = vars[:blinded] || false
      @adjust_procs = adjust_procs

      init_adjust_procs
    end

    # Divides the last element of he sample size array into pieces to run.
    # The sample size array states the already done simulations ss[0..-2], while
    # ss.last = ss[-1] is the sample size to be simulated. This step divides this
    # number into to - the one to be simulated before this profiling takes place
    # and the one to be run afterwards (adapted by the profiling)
    #
    # Examples for result:
    #   adjuster.divide([100]) #=> [20, 80] (at = 20)
    #   adjuster.divide([100]) #=> [50, 50] (at = 0.5)
    #   adjuster.divide([100, 20]) #=> [100, 0, 20] (at = 0.5)
    #   adjuster.divide([20]) #=> [25, 0] (at = 1.25)
    #
    def divide sample_sizes
      total = sample_sizes.sum

      # If at is a precentage use it on the percentage
      if @at.is_a?(Float)
        at_total = (@at * total).round
        # Else use it as a total
      else
        at_total = @at.to_i
      end


      one = (at_total - sample_sizes[0..-2].sum).to_i
      two = (total - at_total).to_i

      # adjusting point in time when we are to late
      # we cannot do anything about this now
      if one < 0
        two += one
        one = 0
      end
      
      # Adjusting overbig profiles (i.e. 1.25 percent)
      if two < 0
        two = 0
      end

      sample_sizes.last = one
      sample_sizes << two
    end

    # Does the internal pilot profiling, calls the sample sizer and adapts the
    # sample size array to the new sample size.
    #
    # Examples for result:
    #   adjuster.profile(*, [100], *) #=> [120] (calculated sample size = 120)
    #   adjuster.profile(*, [100], *) #=> [100] (calculated sample size = 80, restricted = true)
    #   adjuster.profile(*, [15,18], *) #=> [15,15] (calculated sample size = 30, restricted = false)
    #   adjuster.profile(*, [100, 300], *) #=> [100, 300] (calculated sample size = 400, restricted = false)
    def adjust strategy, sample_sizes, data
      variables = {:sample_sizes => sample_sizes}
      @adjust_procs.each do |name, proc|
        variables[name] = proc.call(data, *data)
      end

      # Calculating new sample size
      sample_size = strategy.adjusted_sample_size(variables)
      # How many have we done already - how many are needed to do
      remaining_sample_size = sample_size - sample_sizes[0..-2].sum
      # When we have done them, it cannot be undone
      remaining_sample_size = 0 if remaining_sample_size < 0

      # Applying Sample Size
      if @restricted
        sample_sizes.last = remaining_sample_size if remaining_sample_size > sample_sizes.last
      else
        sample_sizes.last = remaining_sample_size
      end

      variables
    end

    def to_s
      "internal pilot: at #{@at}, restricted #{@restricted}, blinded #{@blinded}"
    end

    def collect_keys index
      index +=1
      ["profiler#{index}_at".to_sym,
        "profiler#{index}_restricted".to_sym,
        "profiler#{index}_blinded".to_sym ]
    end

    def collect_values index
      index +=1
      {"profiler#{index}_at".to_sym => @at,
        "profiler#{index}_restricted".to_sym => @restricted,
        "profiler#{index}_blinded".to_sym => @blinded}
    end

    private
    def init_adjust_procs
      @adjust_procs = {:variance => nil} if @adjust_procs.empty?

      # XXX: At some point it might be nice to use a more generic approach to
      # predefined adjusts
      @adjust_procs.each do |name, proc|
        if proc.nil?
          case name
          when :variance
            @adjust_procs[name] = Proc.new { |sets, *ignore| sets.variance } if @blinded
            @adjust_procs[name] = Proc.new { |sets, *ignore| sets.pooled_variance } unless @blinded
          when :delta
            raise I18n.t("error.cannot_calculate_delta_blinded") if @blinded
            @adjust_procs[name] = Proc.new { |sets, *ignore| sets.delta }
          else
            raise I18n.t("error.adjust_of_non_available_quantity", :value => name) if proc.nil?
          end
        end
      end
    end
  end
end
