class Spree::ProductType < TransactableType
  acts_as_paranoid
  
  has_many :products, class_name: "Spree::Product", inverse_of: :product_type
  belongs_to :user

  def wizard_path
    "/product_types/#{id}/product_wizard/new"
  end

  def buyable?
    true
  end

  def to_liquid
    Spree::ProductTypeDrop.new(self)
  end
end
