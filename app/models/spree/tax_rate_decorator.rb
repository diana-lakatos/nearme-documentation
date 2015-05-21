Spree::TaxRate.class_eval do
  include Spree::Scoper

  validates :amount, numericality: { less_than: 1000 }
end
