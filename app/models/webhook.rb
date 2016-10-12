class Webhook < ActiveRecord::Base
  include Encryptable

  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  attr_encrypted :response, marshal: true

  belongs_to :webhookable, polymorphic: true
  belongs_to :instance

  # Just to make it easier to browse those webhooks in console
  def parse
    webhookable.payment_gateway.parse_webhook(params[:id], webhookable.data[:secret_key])
  end

  def params
    YAML.load(response)
  end
end
