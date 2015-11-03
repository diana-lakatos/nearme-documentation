module SellerAttachments
  extend ActiveSupport::Concern

  def attachments_for_user(user)
    attachments.select { |attachment| attachment.accessible_to?(user) }
  end
end
