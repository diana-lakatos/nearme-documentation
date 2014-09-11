class TransactableTypeAction < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :transactable_type
  belongs_to :action_type

end

