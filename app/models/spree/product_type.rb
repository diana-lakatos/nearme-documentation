class Spree::ProductType < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context
  has_paper_trail
  acts_as_paranoid

  acts_as_custom_attributes_set

  belongs_to :instance
  has_many :products, class_name: "Spree::Product", inverse_of: :product_type
  has_many :form_components, as: :form_componentable

  belongs_to :user

  serialize :custom_csv_fields, Array

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
