class DocumentRequirement < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  MAX_COUNT = 5

  belongs_to :item, -> { with_deleted }, polymorphic: true, inverse_of: :document_requirements
  belongs_to :instance

  validates_presence_of :label, :description, :item

  def is_file_required?
    item.try(:upload_obligation).try(:required?).presence || false
  end
end
