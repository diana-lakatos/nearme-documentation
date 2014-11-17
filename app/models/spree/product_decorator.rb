Spree::Product.class_eval do
  include Spree::Scoper
  include Impressionable

  has_many :line_items, through: :variants
  has_many :orders, through: :line_items

  belongs_to :instance
  belongs_to :user
  belongs_to :company
  belongs_to :administrator, class_name: 'User'
  has_many   :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many   :impressions, as: :impressionable, dependent: :destroy

  scope :approved, -> { where(approved: true) }
  scope :currently_available, -> { where("(#{Spree::Product.quoted_table_name}.available_on <= ? OR #{Spree::Product.quoted_table_name}.available_on IS NULL)", Time.zone.now) }
  scope :searchable, -> { approved.currently_available }

  _validators.reject!{ |key, _| key == :slug }

  _validate_callbacks.reject! do |callback|
    callback.raw_filter.attributes.delete :slug if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :slug, uniqueness: { scope: [:instance_id, :company_id, :partner_id, :user_id] }

  # TODO: uncomment in Phase 3 during implementation of creating products
  # belongs_to :transactable_type, inverse_of: :transactables
  # has_custom_attributes target_type: 'TransactableType', target_id: :transactable_type_id

  store_accessor :status, [:current_status]

  def cross_sell_products
    cross_sell_skus.map do |variant_sku|
      Spree::Variant.where(sku: variant_sku).first.try(:product)
    end.compact
  end

  def to_liquid
    Spree::ProductDrop.new(self)
  end

  def administrator
    super.presence || user
  end

  def has_photos?
    images.count > 0
  end
end
