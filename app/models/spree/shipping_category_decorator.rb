Spree::ShippingCategory.class_eval do
  include Spree::Scoper
  belongs_to :country

  def self.csv_fields
    {name: 'Shipping Category Name'}
  end
end
