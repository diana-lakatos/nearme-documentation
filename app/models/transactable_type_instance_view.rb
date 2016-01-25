class TransactableTypeInstanceView < ActiveRecord::Base
  scoped_to_platform_context
  auto_set_platform_context

  belongs_to :transactable_type, touch: true
  belongs_to :instance_view, touch: true

end

