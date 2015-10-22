Spree::Product.class_eval do
  include Spree::Scoper
  include Impressionable
  include Searchable
  include SitemapService::Callbacks

  attr_accessor :validate_exisiting

  belongs_to :instance
  belongs_to :user, -> { with_deleted }
  belongs_to :company, -> { with_deleted }
  belongs_to :administrator, -> { with_deleted }, class_name: 'User'
  belongs_to :product_type, class_name: "Spree::ProductType", foreign_key: :product_type_id

  has_many :categories_categorizables, as: :categorizable
  has_many :categories, through: :categories_categorizables
  has_many :document_requirements, as: :item, dependent: :destroy
  has_many :impressions, as: :impressionable, dependent: :destroy
  has_many :line_items, through: :variants
  has_many :orders, through: :line_items
  has_many :user_messages, as: :thread_context, inverse_of: :thread_context
  has_many :wish_list_items, as: :wishlistable

  has_one :master,
    -> { where("is_master = ?", true) },
    inverse_of: :product,
    class_name: 'Spree::Variant'

  has_one :upload_obligation, as: :item, dependent: :destroy

  has_custom_attributes target_type: 'Spree::ProductType', target_id: :product_type_id, store_accessor_name: :extra_properties
  delegate :custom_validators, to: :product_type
  delegate :populate_listings_metadata!, to: :user, prefix: true, allow_nil: true

  scope :approved, -> { where(approved: true) }
  scope :draft, -> { where(draft: true) }
  scope :not_draft, -> { where(draft: false) }
  scope :currently_available, -> { not_draft.where("(#{Spree::Product.quoted_table_name}.available_on <= ? OR #{Spree::Product.quoted_table_name}.available_on IS NULL)", Time.zone.now) }
  scope :searchable, -> { approved.currently_available }
  scope :of_type, -> (product_type) { where(product_type: product_type) }
  scope :filtered_by_custom_attribute, -> (property, values) { where("string_to_array((#{Spree::Product.quoted_table_name}.extra_properties->?), ',') && ARRAY[?]", property, values) unless values.blank? }

  scope :price_range, -> (prices) {
    where('
      (SELECT count(spree_prices.*) FROM "spree_prices"  WHERE "spree_prices"."variant_id" = (SELECT  "spree_variants".id FROM "spree_variants"  WHERE "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = spree_products.id AND "spree_variants"."is_master" = \'t\' LIMIT 1)
      AND spree_prices.amount >= ' + prices.first.to_i.to_s + ' AND spree_prices.amount <= ' + prices.last.to_i.to_s + ') > 0
    ')
  }

  scope :for_product_type_id, -> product_type_id { where(product_type_id: product_type_id) }

  scope :with_date, ->(date) { where(created_at: date) }

  _validators.reject! { |key, _| [:slug, :shipping_category_id].include?(key) }

  _validate_callbacks.each do |callback|
    callback.raw_filter.attributes.delete :slug if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
    callback.raw_filter.attributes.delete :shipping_category_id if callback.raw_filter.is_a?(ActiveModel::Validations::PresenceValidator)
  end

  validates :slug, uniqueness: { scope: [:instance_id, :company_id, :partner_id, :user_id] }
  validate :shipping_category_presence
  validates_with CustomValidators

  after_save :set_external_id
  after_commit :user_populate_listings_metadata!, if: :should_populate_user_listings_metadata?

  store_accessor :status, [:current_status]

  accepts_nested_attributes_for :shipping_category

  def self.csv_fields(product_type)
    {
      name: 'Product Name', description: 'Product Description', external_id: 'Product External Id',
      price: 'Price', total_on_hand: 'Quantity', available_on: 'Available On',
      meta_description: 'Meta Description', meta_keywords: 'Meta Keywords',
      products_public: 'Public',  shippo_enabled: 'Shippo Enabled', draft: 'Draft'
    }.reverse_merge(
      product_type.custom_attributes.shared.pluck(:name, :label).inject({}) do |hash, arr|
        hash[arr[0].to_sym] = arr[1].presence || arr[0].humanize
        hash
      end
    )
  end

  def self.search_by_query(attributes = [], query)
    if query.present?
      words = query.split.map.with_index{|w, i| ["word#{i}".to_sym, "%#{w}%"]}.to_h

      sql = attributes.map do |attrib|
        if self.columns_hash[attrib.to_s].type == :hstore
          attrib = "CAST(avals(#{quoted_table_name}.\"#{attrib}\") AS text)"
        else
          attrib = "#{quoted_table_name}.\"#{attrib}\""
        end
        words.map do |word, value|
          "#{attrib} ILIKE :#{word}"
        end
      end.flatten.join(' OR ')

      where(ActiveRecord::Base.send(:sanitize_sql_array, [sql, words]))
    else
      all
    end
  end

  def creator_id
    company.creator_id
  end

  def cross_sell_products
    cross_sell_skus.map do |variant_sku|
      Spree::Variant.where(sku: variant_sku).first.try(:product)
    end.compact
  end

  def to_liquid
    @spree_product_drop ||= Spree::ProductDrop.new(self)
  end

  def administrator
    super.presence || User.with_deleted.find_by(id: user_id)
  end

  def administrator_location
    administrator.current_location ? administrator.country_name : administrator.current_location
  end

  def has_photos?
    images.count > 0
  end

  def reviews
    @reviews ||= Review.for_reviewables(self.line_items.unscope(where: :is_master).pluck(:id), 'Spree::LineItem')
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
    average_rating = reviews.average(:rating) || 0.0
    self.update(average_rating: average_rating)
  end

  def action_free?
    price.to_f.zero?
  end

  def action_free_booking?
    false
  end

  def possible_manual_payment?
    super && product_type.try(:possible_manual_payment)
  end

  def action_rfq?
    super && product_type.try(:action_rfq?)
  end

  def transactable_type_id
    product_type_id
  end

  def translation_namespace
    product_type.try(:translation_namespace)
  end

  def translation_namespace_was
    product_type.try(:translation_namespace_was)
  end

  def should_populate_user_listings_metadata?
    paranoia_destroyed? || %w(id draft).any? { |attr| metadata_relevant_attribute_changed?(attr) }
  end

  def required?(attribute)
    RequiredFieldChecker.new(self, attribute).required?
  end

  private

  def shipping_category_presence
    self.shipping_category.present? || self.shippo_enabled? ? true : errors.add(:shipping_category_id, "shipping category can't be blank")
  end

  def set_external_id
    self.update_column(:external_id, "manual-#{id}") if self.external_id.blank?
  end

  def should_create_sitemap_node?
    !draft? && approved?
  end

  def should_update_sitemap_node?
    !draft? && approved?
  end

  # We override this method because when many records are deleted at once
  # especially if some have a null slug, then the original Spree
  # method may set more than one to have the same new date-based slug
  def punch_slug
    # punch slug with date prefix to allow reuse of original
    update_column :slug, "#{Time.now.to_i}_#{String.get_random_string[0..12]}_#{slug}"[0..254] unless frozen?
  end

end
