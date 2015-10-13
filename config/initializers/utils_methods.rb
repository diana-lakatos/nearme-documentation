class String
  def self.get_random_string
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0..64).map { o[rand(o.length)] }.join
  end
end

