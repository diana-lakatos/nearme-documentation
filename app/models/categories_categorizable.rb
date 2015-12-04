class CategoriesCategorizable < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :category, touch: true
  belongs_to :categorizable, polymorphic: true, touch: true
  belongs_to :transactable_type, -> { where(category_linkable_type: ['TransactableType', 'Spree::Product', 'ProjectType', 'ServiceType']) }
  belongs_to :instance_profile_type, -> { where(category_linkable_type: 'InstanceProfileType') }

end
