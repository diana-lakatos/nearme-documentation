# frozen_string_literal: true
class ValidationHash
  def initialize(hash)
    @hash = hash
  end

  def sanitize
    @hash.each { |k, v| @hash[k] = v.to_sym if v.is_a?(String) }
    @hash
  end
end
