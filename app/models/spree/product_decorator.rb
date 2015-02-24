Spree::Product.class_eval do
  include Spree::Scoper
  include Impressionable

  attr_accessor :validate_exisiting

  has_many :line_items, through: :variants
  has_many :orders, through: :line_items

  belongs_to :instance
  belongs_to :user
  belongs_to :company
  belongs_to :administrator, class_name: 'User'

  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :impressions, as: :impressionable, dependent: :destroy
  has_many :wish_list_items, as: :wishlistable
  has_many :document_requirements, as: :item, dependent: :destroy

  has_one :upload_obligation, as: :item, dependent: :destroy

  scope :approved, -> { where(approved: true) }
  scope :draft, -> { where(draft: true) }
  scope :not_draft, -> { where(draft: false) }
  scope :currently_available, -> { not_draft.where("(#{Spree::Product.quoted_table_name}.available_on <= ? OR #{Spree::Product.quoted_table_name}.available_on IS NULL)", Time.zone.now) }
  scope :searchable, -> { approved.currently_available }

  _validators.reject! { |key, _| [:slug, :shipping_category_id].include?(key) }

  _validate_callbacks.each do |callback|
    callback.raw_filter.attributes.delete :slug if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
    callback.raw_filter.attributes.delete :shipping_category_id if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :slug, uniqueness: { scope: [:instance_id, :company_id, :partner_id, :user_id] }

  validate :shipping_category_presence

  # TODO: uncomment in Phase 3 during implementation of creating products
  # belongs_to :transactable_type, inverse_of: :transactables
  # has_custom_attributes target_type: 'TransactableType', target_id: :transactable_type_id

  store_accessor :status, [:current_status]

  accepts_nested_attributes_for :shipping_category

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

  def administrator_location
    administrator.current_location ? administrator.country_name : administrator.current_location
  end

  def has_photos?
    images.count > 0
  end

  def reviews
    @reviews ||= Review.where(object: 'product', reviewable_type: 'Spree::LineItem', reviewable_id: self.line_items.pluck(:id))
  end

  def reviews_count
    @reviews_count ||= reviews.count
  end

  def has_reviews?
    reviews_count > 0
  end

  def question_average_rating
    @rating_answers_rating ||= RatingAnswer.where(review_id: reviews.pluck(:id))
      .group(:rating_question_id).average(:rating)
  end

  def recalculate_average_rating!
    average_rating = reviews.average(:rating)
    self.update(average_rating: average_rating)
  end

  private

  def shipping_category_presence
    self.shipping_category.present? ? true : errors.add(:shipping_category_id, "shipping category can't be blank")
  end
end
