class SellerAttachment < Ckeditor::Asset
  include Thumbnable

  belongs_to :user

  mount_uploader :data, SellerAttachmentUploader, mount_on: :data_file_name

  validates_inclusion_of :access_level, in: Ckeditor::Asset::ACCESS_LEVELS, allow_nil: true

  validates :data, file_size: { less_than_or_equal_to: 50.megabytes.to_i }

  validate :max_attachments_num, on: :create
  belongs_to :transactable, foreign_key: 'assetable_id'

  scope :for_user, -> (user) { where(user: user) }

  def access_level
    if instance.seller_attachments_enabled?
      instance.seller_attachments_access_sellers_preference? ? super : instance.seller_attachments_access_level
    else
      'disabled'
    end
  end

  def set_initial_access_level
    unless instance.seller_attachments_enabled?
      MarketplaceLogger.error(MarketplaceErrorLogger::BaseLogger::SELLER_ATTACHMENTS_ERROR, 'Tried to set initial access level on SellerAttachment while attachments are disabled', raise: true)
    end

    self.access_level = if instance.seller_attachments_enabled? && !instance.seller_attachments_access_sellers_preference?
                          instance.seller_attachments_access_level
                        else
                          'all'
      end
  end

  private

  def max_attachments_num
    attachments_num = user.attachments.where(assetable_id: nil).count
    attachments_num += assetable.attachments.count if assetable
    unless attachments_num < instance.seller_attachments_documents_num
      errors.add(:base, I18n.t('seller_attachments.max_num_reached'))
    end
  end
end
