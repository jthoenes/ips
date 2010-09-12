# Helper for iterative sample size calculation
module IterationHelper
  include Distribution

  #
  # Iterative calculation of the sample size in two steps:
  #   - fast gauss approximation
  #   - iterative calculation of sample size with central t-distribution
  #
  # Parameters:
  #    ''size'' - the number of groups within the test
  #    ''q1''  - the fist quantile (typically alpha or 1-alpha)
  #    ''q2''  - the second quantile (typically beta or 1-beta)
  #    ''term'' - the constant but test-specific term
  #    ''ratio'' - the weight ratio. Defaults to the arm size when nothing is specified.
  #
  # Note: This iteration is still an approximate. To be correct, we would
  #       need to implement the non-central t-distribution. This is by now
  #       not supported by the apache commons math library. 
  #       However, the sample sizes from this approximation do vary alot from the exact.
  #
  def gauss_t_distribution_iteration size, q1, q2, term, ratio = nil
    ratio ||= size
    # Gauss Approximation
    factor_gauss = (Gauss.quantile(q2) + Gauss.quantile(q1)) ** 2
    n = (factor_gauss * term).ceil
    
    # When the sample size gets smaller than 2, we assume constants.
    # This does not make any sense and leads an error in the central t-approximation
    # As this does not happen with any sensible trial setting in the initial calculation
    # we do set the value to n.
    # In recalculation this does not have any effect, as 2 per arm will for sure be smaller
    # Than the already allocated patients n_1
    #
    if n < 2
      # Logger['test_strategy'].warn "Starting n in iterative calculation of sample-size adjusted from #{n} to 2."
      n = 2
    end
    
    # 
    # Classic approximation of the non-central t-distribution with the central t-distribution
    #
    loop do
      factor = (StudentT.quantile(q1, (n*ratio).ceil - size) + StudentT.quantile(q2, (n*ratio).ceil - size))**2
      # We are done, if our n satisfies the condition
      break if n >= term * factor
      n += 1
    end
    # Return the sample size for ALL arms, rather than for one
    (n * ratio).ceil
  end



  # Determine the smallest integer, that satisfies a passed condition. 
  # Uses the binary search mechanism, skip some interation steps.
  # 
  # You could call i.e. for a (simple) test like if n is bigger than 10_000 like this:
  #     
  #    n = iterate_up{|i| i > 10_000}
  # 
  #  The methods starts with finding the upper bound by first iterate up. You can control this by
  # defining the start and the step parameters:
  #
  #   ''start'' Define the start number of the iteration. The smallest satisfy must not be smaller
  #   ''step''  The size of the stepping iteration before the binary search starts.
  #
  def iterate_up start = 0, step = 1000, &block
    last = start
    max = start
    # First we need to find the a maximum, because i theory we have infinite integers
    # I define the step parameters, as for some sample size calculation, there is a way to guess those to
    #   some extend.
    # I could of course start with Fixnum::MAX but I in my case this is faster
    until(yield(max))
      last = max
      max += step
    end

    # Now that we know the range where to look for the smallest match
    find_smallest_satisfier(last, max, &block)
  end


  private
  # This works nearly exactly as textbooks binary search
  def find_smallest_satisfier min, max, &block
    # Assure all conditions apply to do a binary search, without errors
    assert {min > 0}
    assert {max > 0}
    assert {max >= min}

    # If min and max differ less than 2, we have found the smallest n
    if max - min < 2
      ret = yield(min)
      return min if ret
      return max
    end

    # Get the value in the middle
    n = min + (max-min)/2

    # If yield(n) ==> value might be smaller
    if yield(n)
      return find_smallest_satisfier(min, n, &block)
      # Unless yield(n) ==> value might be bigger
    else
      return find_smallest_satisfier(n, max, &block)
    end
  end
end
