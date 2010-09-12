class Numeric

	def generate times
		[self] * times
	end

  def inverse
    - self
  end

  def to_a
    [self]
  end
end
