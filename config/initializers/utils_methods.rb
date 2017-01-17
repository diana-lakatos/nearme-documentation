class Object
  # We do this because arrays among others can end up (and did) as parameters
  # and simple to_i doesn't work on them
  def to_pagination_number(default = 1)
    number = to_i rescue default
    number = default if number.zero?
    number
  end
end
