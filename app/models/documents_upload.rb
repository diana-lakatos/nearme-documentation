class DocumentsUpload < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_paranoid

  REQUIREMENTS = [:mandatory, :optional, :vendor_decides]

  belongs_to :instance

  validates_presence_of :requirement

  def is_enabled?
    enabled || errors.present?
  end

  def is_mandatory?
    requirement == 'mandatory'
  end

  def is_optional?
    requirement == 'optional'
  end

  def is_vendor_decides?
    requirement == 'vendor_decides'
  end

  def force_file_upload?
    is_enabled? && requirement =~ /mandatory|optional/
  end

  def to_obligation
    UploadObligation::LEVELS[REQUIREMENTS.index(requirement.to_sym)]
  end
end
