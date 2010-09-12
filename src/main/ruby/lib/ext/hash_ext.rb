class Hash
  #
  # Enables the hash to be a single key-value pair.
  # If +self+ has only one element, one can call the +key+ and the +value+ method
  # to get the single key value pair.
  #
  def method_missing(symbol, *args)
    if args.empty? && size == 1
      if symbol == :key
        keys.only
      elsif symbol == :value
        values.only
      end
    end
    super
  end
end
