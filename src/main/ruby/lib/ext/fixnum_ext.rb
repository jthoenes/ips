# Extends the Ruby base class fixnum with the convinience methods +million+,
# +thousand+ und +hundred+.
class Fixnum
  # +self+ times one million (10^6).
  def million
    self * 10**6
  end


  # +self+ times one thousand (10^3).
  def thousand
    self * 10**3
  end

  # +self+ times one hundred (10^2).
  def hundred
    self * 10 ** 2
  end
end
