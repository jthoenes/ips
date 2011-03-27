module DSLProxy
  class SingleCollect < Base
     include Reporting

    def before_call
      @observer = SingleObserver.new
    end

    def after_call
      @instructions.single_observer << @observer unless @observer.empty?
    end

    protected
    def method_missing method, *args
       raise I18n.t("error.reporting.no_series_quantity",
        :value => method) unless SingleResult.check_call(method, args)
      @observer << method
    end
  end
end
