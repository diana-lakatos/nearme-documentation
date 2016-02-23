class CategoriesCategorizable < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :category, touch: true
  belongs_to :categorizable, polymorphic: true, touch: true
  belongs_to :transactable, -> { where(categories_categorizables: { categorizable_type: 'Transactable' } ) }, foreign_key: :categorizable_id

end
