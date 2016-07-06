class TransactableTopic < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :transactable
  belongs_to :topic

  has_many :data_source_contents, through: :topic
end
