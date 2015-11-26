Spree::LineItem.class_eval do
  include Spree::Scoper
  inherits_columns_from_association([:company_id], :order) if ActiveRecord::Base.connection.table_exists?(self.table_name)
  delegate :transactable_type_id, :product_type, to: :product
  delegate :owner_id, to: :order
  delegate :creator_id, to: :product

  has_many :reviews, as: :reviewable

  def has_seller_reviews?
    Review.by_line_items(self.id).where(rating_system_id: RatingSystem.for_hosts.pluck(:id)).present?
  end

  def has_product_reviews?
    Review.by_line_items(self.id).where(rating_system_id: RatingSystem.for_transactables.pluck(:id)).present?
  end

  def to_liquid
    @spree_line_item_drop ||= Spree::LineItemDrop.new(self)
  end

  def seller_type_review_receiver
    product.administrator
  end

  def buyer_type_review_receiver
    order.user
  end

  def price_in_cents
    monetize(price).cents
  end

end
