Spree::Product.class_eval do
  include TransactableType::CustomAttributesCaster
  include Spree::Scoper

  has_many :line_items, through: :variants
  has_many :orders, through: :line_items

  belongs_to :instance

  _validators.reject!{ |key, _| key == :slug }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :slug if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :slug, uniqueness: { scope: [:instance_id, :company_id, :partner_id, :user_id] }

  after_initialize :apply_transactable_type_settings

  store_accessor :status, [:current_status]

  def apply_transactable_type_settings
    set_custom_attributes(:extra_properties)
  end

  def transactable_type_attributes
    return [] if self.instance.transactable_types.empty?
    @transactable_type_attributes ||= self.instance.transactable_types.first.transactable_type_attributes
  end

  def transactable_type_attributes_names_types_hash
    return {} if !self.instance.present?
    @transactable_type_attributes_names_types_hash ||= self.transactable_type_attributes.inject({}) do |hstore_attrs, attr|
      hstore_attrs[attr.name.to_sym] = attr.attribute_type.to_sym
      hstore_attrs
    end
  end
end
