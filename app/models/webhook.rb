class Webhook < ActiveRecord::Base
  include Encryptable

  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :response, marshal: true

  belongs_to :webhookable, polymorphic: true
  belongs_to :instance

end
