class ErrorFilter

  attr_reader :errors

  def initialize(errors)
    @errors = errors
  end

  def filter
    keys = errors.keys
    keys.each do |k|
      errors.delete(k) if keys.any? { |k2| k2.to_s.start_with?(k.to_s) && (k2.to_s != k.to_s)}
    end

    errors
  end
end
