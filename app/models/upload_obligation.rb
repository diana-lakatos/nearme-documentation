class UploadObligation < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  LEVELS = ['Required', 'Optional', 'Not Required']

  validates_inclusion_of :level, in: LEVELS

  belongs_to :item, polymorphic: true, inverse_of: :upload_obligation
  belongs_to :reservation, polymorphic: true, inverse_of: :upload_obligation
  belongs_to :instance

  def required?
    level == LEVELS[0]
  end

  def optional?
    level == LEVELS[1]
  end

  def not_required?
    level == LEVELS[2]
  end

  def self.default_level
    if PlatformContext.current.instance.documents_upload.present? &&
       PlatformContext.current.instance.documents_upload.is_mandatory?
      LEVELS[0]
    elsif PlatformContext.current.instance.documents_upload.present? &&
          PlatformContext.current.instance.documents_upload.is_optional?
      LEVELS[1]
    else
      LEVELS[2]
    end
  end
end
