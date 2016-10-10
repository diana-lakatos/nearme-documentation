class Fixnum
  def ordinal
    ordinalize.gsub(/\d+/, '')
  end
end
