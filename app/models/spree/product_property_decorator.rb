Spree::ProductProperty.class_eval do
  include Spree::Scoper

  attr_accessor :property_name

  belongs_to :company

  before_validation :find_or_create_property

  def property_name
    property.try(:name) || @property_name
  end

  private

  def find_or_create_property
    return false if property_name.blank? || company_id.blank?
    unless property = Spree::Property.find_by(name: property_name, company_id: company_id)
      property = Spree::Property.create(name: property_name, presentation: property_name, company_id: company_id)
    end
    self.property = property
  end

end
