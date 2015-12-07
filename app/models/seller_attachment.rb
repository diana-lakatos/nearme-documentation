class SellerAttachment < Ckeditor::Asset

  ACCESS_LEVELS = %w(all users purchasers)

  include Thumbnable

  belongs_to :user

  mount_uploader :data, SellerAttachmentUploader, mount_on: :data_file_name

  validates_inclusion_of :access_level, in: ACCESS_LEVELS, allow_nil: true

  validate :max_attachments_num, on: :create

  def access_level
    if instance.seller_attachments_enabled?
      instance.seller_attachments_access_sellers_preference? ? super : instance.seller_attachments_access_level
    else
      'disabled'
    end
  end

  def set_initial_access_level
    if !instance.seller_attachments_enabled?
      Rails.application.config.marketplace_error_logger.log_issue(MarketplaceErrorLogger::BaseLogger::SELLER_ATTACHMENTS_ERROR, "Tried to set initial access level on SellerAttachment while attachments are disabled", raise: true)
    end

    self.access_level = if instance.seller_attachments_enabled? && !instance.seller_attachments_access_sellers_preference?
        instance.seller_attachments_access_level
      else
        'all'
      end
  end

  ACCESS_LEVELS.each do |al|
    define_method "accessible_to_#{al}?" do
      access_level == al
    end
  end

  def accessible_to?(user)
    if accessible_to_all?
      true
    elsif accessible_to_users?
      !!user
    elsif accessible_to_purchasers?
      if user.present?
        if assetable.is_a?(Transactable)
            !!user.reservations.confirmed.find_by(transactable_id: assetable_id)
        else assetable.is_a?(Spree::Product)
          !!user.orders.complete.map { |o| o.line_items.map(&:product) }.flatten.include?(assetable)
        end
      else
        false
      end
    else
      raise ArgumentError
    end
  end

  def to_liquid
    @seller_attachment_drop ||= SellerAttachmentDrop.new(self)
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
