class Ckeditor::Asset < ActiveRecord::Base
  include Ckeditor::Orm::ActiveRecord::AssetBase
  auto_set_platform_context
  scoped_to_platform_context

  mount_uploader :data, BaseCkeditorUploader, mount_on: :data_file_name

  ACCESS_LEVELS = %w(all users listers enquirers purchasers collaborators).freeze
  GLOBAL_ASSET_ACCESS_LEVELS = %w(listers enquirers).freeze

  delegate :url, :current_path, :content_type, to: :data
  validates :data, presence: true

  belongs_to :instance
  belongs_to :user

  class << self
    def user_friendly_global_asset_access_levels
      return GLOBAL_ASSET_ACCESS_LEVELS unless PlatformContext.current.decorate.single_type?
      @tt = PlatformContext.current.decorate.transactable_types.first
      # must have same values as GLOBAL_ASSET_ACCESS_LEVELS
      [[@tt.translated_lessor, 'listers'], [@tt.translated_lessee, 'enquirers']]
    end

    def friendly_access_level_name(access_level)
      return GLOBAL_ASSET_ACCESS_LEVELS unless PlatformContext.current.decorate.single_type?
      @tt = PlatformContext.current.decorate.transactable_types.first
      case access_level
      when 'listers'
        @tt.translated_lessor
      when 'enquirers'
        @tt.translated_lessee
      else
        access_level
      end
    end
  end

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
