class Spree::ProductType < TransactableType

  has_many :form_components, as: :form_componentable
  has_many :categories, as: :categorizable, dependent: :destroy
  has_many :products, class_name: "Spree::Product", inverse_of: :product_type

  belongs_to :user

  def wizard_path
    "/product_types/#{id}/product_wizard/new"
  end

  def buyable?
    true
  end

  def create_rating_systems
    [instance.lessor, name].each do |subject|
      rating_system = instance.rating_systems.create(subject: subject, transactable_type_id: id)
      RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.create(value: value, instance: instance) }
    end
  end

  def to_liquid
    Spree::ProductTypeDrop.new(self)
  end
end
