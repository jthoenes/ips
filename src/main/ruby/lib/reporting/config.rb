module Reporting
  class Config
    include Singleton

    attr_accessor :output_folder, :outstream, :errstream
    attr_reader :result_files

    def initialize
      @output_folder = Dir.tmpdir
      @result_files = []
    end

    def create_filename *format
      return '/dev/null' if @silence
      
      parts = sim_config.dsl_file.split('.').reject{|p| p =~ /^(rb|dsl)$/ }
      parts += format
      filename = File.join(@output_folder, parts.join('.'))
      @result_files << filename unless @result_files.include?(filename)
      filename
    end

    def runs
      sim_config.runs
    end

    def silence
      @silence = true
    end

    private
    def sim_config
      @sim_config ||= Sim::Config.instance
    end
  end
end
