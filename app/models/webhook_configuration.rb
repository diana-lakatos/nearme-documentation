# frozen_string_literal: true
class WebhookConfiguration < ActiveRecord::Base
  include Modelable
  include Encryptable

  attr_encrypted :signing_secret, marshal: true

  belongs_to :payment_gateway
  has_many :webhooks

  def path
    "/webhooks/#{id}/listen"
  end

end
