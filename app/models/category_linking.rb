class CategoryLinking < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :category, touch: true
  belongs_to :category_linkable, polymorphic: true, touch: true
end
