#
# Exension of the ruby base class +Object+ for enabling checking for assertions.
#
class Object
  # Basic assertion expecting the block passed to yield +true+, otherwise
  # an assertion error is raised.
	def assert
    unless yield
      # Cleaning the stack-trace from all assert methods, so it appears
      # the exception was directly raised by the assert statement (like in java)
      stack_trace = caller.reject{|c| c =~ /__FILE__/}
      raise StandardError, "Assertion failed!", stack_trace
    end
	end

  #
  # Check that all arguments are probabilites i.e. the are numbers between 0.0
  # and 1.0
	def assert_probability *args
		assert_floatable(*args)
		args.each do |var|
			assert do
        var >= 0.0 &&
					var <= 1.0
			end
		end
	end

  # Checks that all arguments are float or can be converted to a float.
  def assert_floatable *args
    args.each do |var|
      assert do
        var.not_nil? && var.is_a?(Numeric)
      end
    end
  end

  # Checks that all arguments are symbols.
  def assert_symbol *args
    args.each{|a| assert{a.is_a?(Symbol)}}
  end

  # Checks that all arguments are a Proc object or +nil+.
  def assert_proc_or_nil *args
    args.each{|a| assert{a.nil? || a.is_a?(Proc)}}
  end
end