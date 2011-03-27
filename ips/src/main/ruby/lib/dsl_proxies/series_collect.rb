module DSLProxy
  class SeriesCollect < Base
    include Reporting
    
    def before_call
      @series_observer = SeriesObserver.new
      @single_observer = SingleSeriesObserver.new
    end

    def after_call
      @instructions.series_observer << @series_observer
      @instructions.single_observer << @single_observer
    end

    protected
    def method_missing method, *args
      raise I18n.t("error.reporting.no_series_quantity",
        :value => method) unless SeriesResult.check_call(method, args)
      @series_observer << [method, args]
      SeriesResult.requirements(method, args).each {|r| @single_observer << r}
    end
  end
end