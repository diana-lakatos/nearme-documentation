class String
  def self.get_random_string
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0..64).map { o[rand(o.length)] }.join
  end
end

class Object
  # We do this because arrays among others can end up (and did) as parameters
  # and simple to_i doesn't work on them
  def to_pagination_number(default = 1)
    number = self.to_i rescue default
    number = default if number.zero?
    number
  end
end

