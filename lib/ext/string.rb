class String

  def intersection(other)
    str = self.dup
    other.chars.inject(0) do |sum, char|
      sum += 1 if str.sub!(char,'')
      sum
    end
  end

end

