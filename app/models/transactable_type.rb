class TransactableType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  MAX_PRICE = 2147483647

  attr_accessible :name, :pricing_options, :pricing_validation
  has_many :transactables, inverse_of: :transactable_type
  has_many :transactable_type_attributes, inverse_of: :transactable_type

  belongs_to :instance

  serialize :pricing_options, Hash
  serialize :pricing_validation, Hash

  after_save :setup_price_attributes, :if => lambda { |transactable_type| transactable_type.pricing_options_changed? || transactable_type.pricing_validation_changed? }
  after_destroy :setup_price_attributes

  validate :pricing_validation_is_correct

  def pricing_options
    super.select { |k,v| v == "1" }
  end

  def pricing_options_long_period_names
    pricing_options.keys.reject { |k| %w(free hourly).include?(k) }
  end

  def pricing_validation_is_correct
    self.pricing_validation.each do |price, pair|
      if pair["min"].present? && pair["max"].present?
        errors.add("pricing_validation[#{price}]['min']", "min can't be greater than max") if pair["min"].to_i > pair["max"].to_i
      end
      errors.add("pricing_validation[#{price}]['min']", "min can't be lower than zero") if pair["min"].present? && pair["min"].to_i < 0
      errors.add("pricing_validation[#{price}]['max']", "max can't be greater than #{MAX_PRICE}") if pair["max"].present? && pair["max"].to_i > MAX_PRICE
    end
  end

  def setup_price_attributes
    { "free" => "free", "hourly" => "hourly_reservations" }.each do |field, attribute|
      if pricing_options.keys.include?(field)
        transactable_type_attributes.create(name: attribute, attribute_type: :boolean, public: false, internal: true) unless transactable_type_attributes.where(:name => attribute).first.present?
      else
        transactable_type_attributes.where(:name => attribute).first.try(:destroy)
      end
    end
    %w(daily weekly monthly hourly).each do |price|
      price_field = "#{price}_price_cents"
      if pricing_options.keys.include?(price)
        tta = transactable_type_attributes.where(:name => price_field).first.presence || transactable_type_attributes.build(name: price_field)
        tta.attributes = {attribute_type: :integer, public: false, internal: true, validation_rules: build_validation_rule_for(price) }
        tta.save!
      else
        transactable_type_attributes.where(:name => price_field).first.try(:destroy)
      end
    end
  end

  def build_validation_rule_for(price)
    @greater_than = 0
    @less_than = MAX_PRICE
    if pricing_validation[price].present?
      @greater_than = pricing_validation[price]["min"].to_i if pricing_validation[price]["min"].present?
      @less_than = pricing_validation[price]["max"].to_i if pricing_validation[price]["max"].present?
    end
    { :numericality => { redirect: "#{price}_price", allow_nil: true, greater_than_or_equal_to: @greater_than, less_than_or_equal_to: @less_than } }
  end
end

