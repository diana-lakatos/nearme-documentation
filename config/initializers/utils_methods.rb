class Object
  # We do this because arrays among others can end up (and did) as parameters
  # and simple to_i doesn't work on them
  def to_pagination_number(default = 1)
    number = to_i rescue default
    number = default if number.zero?
    number
  end

  def utf8_convert_sanitize
    if self.is_a?(String)
      encode('utf-8', invalid: :replace, undef: :replace, replace: '')
    elsif self.is_a?(Array)
      collect(&:utf8_convert_sanitize)
    elsif self.is_a?(Hash)
      inject({}) { |h, (k, v)| h[k] = v.utf8_convert_sanitize; h }
    else
      self
    end
  end
end
