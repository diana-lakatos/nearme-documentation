class MarketplaceRelease < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  mount_uploader :zip_file, MarketplaceReleaseUploader

  enum status: [:ready_for_import, :ready_for_export, :success, :error]

  belongs_to :instance

  validates :zip_file, presence: true, if: :ready_for_import?
end
