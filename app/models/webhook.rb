class Webhook < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  attr_encrypted :response, key: DesksnearMe::Application.config.secret_token, if: DesksnearMe::Application.config.encrypt_sensitive_db_columns, marshal: true

  belongs_to :webhookable, polymorphic: true
  belongs_to :instance

end
