class CategoryLinking < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :category, touch: true
  belongs_to :category_linkable, polymorphic: true, touch: true
  belongs_to :service_type, -> { where(category_linkings: { category_linkable_type: 'ServiceType' } ) }, foreign_key: 'category_linkable_id'
  belongs_to :product_type, -> { where(category_linkings: { category_linkable_type: 'Spree::ProductType' } ) }, foreign_key: 'category_linkable_id', class_name: 'Spree::ProductType'
  belongs_to :project_type, -> { where(category_linkings: { category_linkable_type: 'ProjectType' } ) }, foreign_key: 'category_linkable_id'
  belongs_to :instance_profile_type, -> { where(category_linkings: { category_linkable_type: 'InstanceProfileType' } ) }, foreign_key: 'category_linkable_id'

end
