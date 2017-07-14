# frozen_string_literal: true
class ValidationHash
  def initialize(hash)
    @hash = hash
  end

  def sanitize
    sanitize_hash(@hash)
  end

  protected

  def sanitize_hash(hash)
    hash.each do |k, v|
      next if %i(message).include?(k)
      hash[k] = case v
                when Hash
                  sanitize_hash(v)
                when String
                  convert_string(v)
                when TrueClass, FalseClass, Regexp, Numeric, Array, Symbol
                  v
                else
                  raise NotImplementedError, "Unexpected type of value passed to sanitize_hash: #{v.class.name}"
                end
    end
    hash
  end

  def convert_string(v)
    if v[0] == '/' && v[-1] == '/'
      Regexp.new(v[1..-2])
    else
      v.to_sym
    end
  end
end
