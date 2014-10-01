Spree::Product.class_eval do
  include Spree::Scoper

  has_many :line_items, through: :variants
  has_many :orders, through: :line_items

  belongs_to :instance

  _validators.reject!{ |key, _| key == :slug }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :slug if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :slug, uniqueness: { scope: [:instance_id, :company_id, :partner_id, :user_id] }

  # TODO: in Phase 2
  #after_initialize :apply_transactable_type_settings

  store_accessor :status, [:current_status]

end
