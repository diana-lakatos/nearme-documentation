class MerchantAccountOwner < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  mount_uploader :document, MerchantAccountOwnerDocumentUploader

  serialize :data, Hash
end
