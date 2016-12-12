# frozen_string_literal: true
class MerchantAccountOwner < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  mount_uploader :document, MerchantAccountOwnerDocumentUploader

  serialize :data, Hash

  def to_liquid
    @maod ||= MerchantAccountOwnerDrop.new(self)
  end
end
