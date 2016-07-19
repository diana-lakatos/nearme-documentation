class CategoryLinking < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :category, touch: true
  belongs_to :category_linkable, polymorphic: true, touch: true
  belongs_to :transactable_type, -> { where(category_linkings: { category_linkable_type: 'TransactableType' } ) }, foreign_key: 'category_linkable_id'
  belongs_to :project_type, -> { where(category_linkings: { category_linkable_type: 'ProjectType' } ) }, foreign_key: 'category_linkable_id'
  belongs_to :instance_profile_type, -> { where(category_linkings: { category_linkable_type: 'InstanceProfileType' } ) }, foreign_key: 'category_linkable_id'
  belongs_to :reservation_type, -> { where(category_linkings: { category_linkable_type: 'ReservationType' } ) }, foreign_key: 'category_linkable_id'

end
