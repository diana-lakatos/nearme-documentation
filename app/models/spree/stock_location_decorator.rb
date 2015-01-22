Spree::StockLocation.class_eval do
  include Spree::Scoper

  belongs_to :company

  accepts_nested_attributes_for :stock_items

  def create_stock_items
    self.company.variants.find_each { |variant| self.propagate_variant(variant) } if self.company
  end
end
