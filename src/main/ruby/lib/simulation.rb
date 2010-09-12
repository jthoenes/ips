$:.unshift File.join(File.dirname(__FILE__))
require 'loader'

def simulate &block
  $proxies = DSLProxy::Simulation.new(&block)
  $proxies.call
  $instructions = $proxies.instructions
  $instructions.prepare
  
  plot_proxies = DSLProxy::Simulation.new(Plotting::PlotModel.new, &block)
  plot_proxies.call
  $plot_model = plot_proxies.instructions

  $instructions
end

def load_simulation_file(filename)
  raise "No argument passed" if filename.nil?
  raise "Simulation File does not exist" unless File.exists?(filename)
  config = Sim::Config.instance
  config.dsl_file = filename
  load filename
end

def run_simulation
  $instructions.process
end
