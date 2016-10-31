class StandardValidator
  TYPE_TO_KLASS = {
    presence: ActiveModel::Validations::PresenceValidator,
    inclusion: ActiveModel::Validations::InclusionValidator,
    numericality: ActiveModel::Validations::NumericalityValidator,
    length: ActiveModel::Validations::LengthValidator
  }.freeze

  ADDITIONAL_OPTIONS = {
    length: { allow_blank: true },
    numericality: { allow_blank: true },
    inclusion: { allow_blank: true }
  }.freeze

  def initialize(record:, field_name:, validation_rules: {})
    @record = record
    @field_name = field_name
    @validation_rules = validation_rules
  end

  def validate
    return true if @validation_rules.blank?
    @validation_rules.each do |validation_rule_type, validation_rule_options|
      type = validation_rule_type.to_sym
      normalized_options = normalize_validation_rule_options(validation_rule_options)
                           .merge(ADDITIONAL_OPTIONS.fetch(type, {}))
      TYPE_TO_KLASS.fetch(type).new(normalized_options).validate(@record)
    end
  end

  protected

  def normalize_validation_rule_options(options = {})
    options[:attributes] = options.fetch('redirect', @field_name)
    options.tap(&:symbolize_keys!)
  end
end
