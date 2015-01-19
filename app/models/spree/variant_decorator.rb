Spree::Variant.class_eval do
  include Spree::Scoper
  belongs_to :company
end
