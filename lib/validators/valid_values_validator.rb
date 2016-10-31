class ValidValuesValidator
  class Value
    def initialize(value)
      @value = normalize_value(value)
    end

    def included_in?(array)
      array.detect(&method(:eql?))
    end

    def present?
      @value.present?
    end

    def eql?(other)
      @value == normalize_value(other)
    end

    def to_s
      @value.to_s
    end

    protected

    def normalize_value(value)
      return nil if value.blank?
      return value unless value.is_a?(String)
      value.mb_chars.downcase
    end
  end

  def initialize(record:, field_name:, valid_values:)
    @record = record
    @field_name = field_name
    @value = Value.new(@record.send(field_name))
    @valid_values = valid_values
  end

  def validate
    return true unless @value.present? && @valid_values.try(:any?)
    @record.errors.add(@field_name,
                       :inclusion,
                       value: @value) unless @value.included_in?(@valid_values)
  end
end
