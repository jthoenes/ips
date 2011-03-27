module Reporting
  class SeriesOutputter
    def initialize
      @filename = Config.instance.create_filename 'csv'
    end

    def append instruction, result
      @csv ||= FasterCSV.open(@filename, 'wb')
      data_hash = instruction.parameters.merge(result)
      if @headline_written.nil?
        @headline_written = true
        @csv << data_hash.keys
      end
      @csv << data_hash.values
    end

    def close
      @csv.close
    end
  end
end
