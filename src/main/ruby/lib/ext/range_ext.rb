class Range
  
  def step step_size, &block
    current = self.begin
    arr = []
    loop do
      arr << current if include?(current)
      current += step_size
      break unless include?(current)
    end

    if block_given?
      arr.each(&block)
    else
      arr
    end
  end
end
