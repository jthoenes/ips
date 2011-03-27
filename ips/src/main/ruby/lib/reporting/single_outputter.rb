module Reporting
  class SingleOutputter
    def initialize(instruction)
      @filename = Config.instance.create_filename instruction.index, 'csv'
    end

    def append result
      @csv ||= FasterCSV.open(@filename, 'wb')
      if @headline_written.nil?
        @headline_written = true
        @csv << result.keys
      end
      @csv << result.values
    end

    def close
      @csv.close
    end
  end
end
