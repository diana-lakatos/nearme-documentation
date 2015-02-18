class Spree::ProductType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  acts_as_custom_attributes_set
	auto_set_platform_context

  belongs_to :instance
  has_many :products, class_name: "Spree::Product", inverse_of: :product_type
  has_many :form_components, as: :form_componentable

  belongs_to :user

  scoped_to_platform_context
  
  def wizard_path
    "/product_types/#{id}/product_wizard/new"
  end
end