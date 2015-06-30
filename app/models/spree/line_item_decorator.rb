Spree::LineItem.class_eval do
  include Spree::Scoper
  inherits_columns_from_association([:company_id], :order) if ActiveRecord::Base.connection.table_exists?(self.table_name)

  has_many :reviews

  def has_seller_reviews?
    Review.by_line_items(self.id).where(object: 'seller').present?
  end

  def has_product_reviews?
    Review.by_line_items(self.id).where(object: 'product').present?
  end

  def to_liquid
    Spree::LineItemDrop.new(self)
  end

  def seller_type_review_receiver
    product.administrator
  end

  def buyer_type_review_receiver
    order.user
  end
end
