module DSLProxy
  class Collect < Base
    include SubproxyHelper

    dsl_subproxy :single => SingleCollect
    dsl_subproxy :series => SeriesCollect

    def before_call
      @config = Reporting::Config.instance
    end

    def raw_data
      @raw_data = true
    end


    def folder folder
      @config.output_folder = folder
    end
  end
end

