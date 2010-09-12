module Plotting
  class PseudoArray
    def initialize plot_model
      @plot_model = plot_model
    end

    def <<(ele)
      ele.collect.each do |c|
        if c.last.empty?
	  @plot_model.y_axis_options << c.first.to_s
	else
	  if c.last.first == :means
	    @plot_model.y_axis_options << "treatment_#{c.first.to_s}"
	    @plot_model.y_axis_options << "control_#{c.first.to_s}"
	    @plot_model.y_axis_options << "placebo_#{c.first.to_s}"
	  else
	    @plot_model.y_axis_options << "#{c.last.first}_#{c.first.to_s}"
	  end
	end
      end
    end
  end

  class PlotModel
    attr_accessor :result_file, :y_axis_options, :vary_options

    def initialize
      @result_file = Reporting::Config.instance.create_filename 'csv'
      @vary_options = []
      @y_axis_options = []
      @pseudo_array = PseudoArray.new(self)
    end

    def arms=(arms)
      arms.transpose.each do |arm|
        @vary_options << "#{arm.first.name}_mean" if arm.map(&:mean).uniq.size > 1
        @vary_options << "#{arm.first.name}_variance" if arm.map(&:variance).uniq.size > 1
        @vary_options << "#{arm.first.name}_weight" if arm.map(&:weight).uniq.size > 1
      end
    end

    # Dummy, no variance happening here
    def strategy=(s); end

    def test_variables=(vars)
      handle_variables vars, 'test'
    end

    def sample_size_variables=(vars)
      handle_variables vars, 'planned'
    end

    def test_adds=(adds)
      handle_variables adds, 'test'
    end

    def sample_size_adds=(adds)
      handle_variables adds, 'planned'
    end

    def add_profiler(prof)
      @vary_options << "profiler1_at" if prof.map(&:at).reject(&:nil?).uniq.size > 1
      @vary_options << "profiler1_restricted" if prof.map(&:restricted).reject(&:nil?).uniq.size > 1
      @vary_options << "profiler1_blinded" if prof.map(&:blinded).reject(&:nil?).uniq.size > 1
    end

    def series_observer
      @pseudo_array
    end

    def single_observer
      []
    end

    def handle_variables vars, prefix
      if vars.size > 1
	vars.first.each_key do |key|
	  @vary_options << "#{prefix}_#{key}" if vars.map{|v| v[key]}.uniq.size > 1
	end
      end
    end

    # Dummies
    def strategy=(strategy)
    end

    def strategy
      @strategy ||= TestStrategy::None.new
    end
  end
end


def simulate &block
  $proxies = DSLProxy::Simulation.new(Plotting::PlotModel.new, &block)
  $proxies.call
  $plot_model = $proxies.instructions
end
