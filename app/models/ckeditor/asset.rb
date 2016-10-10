class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  auto_set_platform_context
  scoped_to_platform_context

  mount_uploader :data, BaseCkeditorUploader, mount_on: :data_file_name

  ACCESS_LEVELS = %w(all users listers enquirers purchasers collaborators).freeze
  GLOBAL_ASSET_ACCESS_LEVELS = %w(listers enquirers).freeze

  delegate :url, :current_path, :content_type, to: :data
  validates_presence_of :data

  belongs_to :instance

  ACCESS_LEVELS.each do |al|
    define_method "accessible_to_#{al}?" do
      access_level == al
    end
  end

  def accessible_to?(user)
    ::SellerAttachment::Fetcher.new(user).has_access_to?(self)
  end

  def to_liquid
    @ckeditor_asset_drop ||= CkeditorAssetDrop.new(self)
  end
end
