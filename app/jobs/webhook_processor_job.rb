class WebhookProcessorJob < Job
  def after_initialize(webhook_id)
    @webhook_id = webhook_id
  end

  def perform
    Webhook.find(@webhook_id).process!
  end
end
