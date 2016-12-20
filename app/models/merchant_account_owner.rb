# frozen_string_literal: true
class MerchantAccountOwner < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  mount_uploader :document, MerchantAccountOwnerDocumentUploader

  serialize :data, Hash

  def to_liquid
    @maod ||= MerchantAccountOwnerDrop.new(self)
  end
end
