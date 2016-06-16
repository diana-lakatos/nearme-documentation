class GroupProject < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :group
  belongs_to :project
end
