class Array
  def not_empty?
    size != 0
  end
  
	def count &block
		select(&block).size
	end
  
  def inverse
    map{|n| n.inverse}
  end

  def embedd
    size == 1 ? only : self
  end

end
