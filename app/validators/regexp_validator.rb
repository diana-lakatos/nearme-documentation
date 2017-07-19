class RegexpValidator
  def initialize(record:, field_name:, regexp:)
    @record = record
    @field_name = field_name
    @regexp = regexp
  end

  def validate
    return true unless @regexp.present? && value.present?
    @record.errors.add(@field_name, I18n.t('errors.messages.has_an_invalid_format')) unless value_matches_regexp?
  end

  protected

  def value_matches_regexp?
    /#{@regexp}/.match(value)
  end

  def value
    @record.send(@field_name)
  end
end
