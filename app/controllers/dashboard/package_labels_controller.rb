class Dashboard::PackageLabelsController < ApplicationController
  def show
    return handle_label_not_found if label.nil?

    send_data fetch_label.body, filename: filename
  end

  private

  def filename
    format('shipping-label-%s-%s.pdf', params[:delivery_id], params[:id])
  end

  def delivery
    @delivery ||= Delivery.find(params[:delivery_id])
  end

  def label
    Array(delivery.labels).find { |label| label['size'] == params[:id] }
  end

  def fetch_label
    FetchLabelRequest.new(delivery, label.url).perform
  end

  def handle_label_not_found
    SyncDeliveryStateJob.perform(delivery.order_id)

    redirect_to :back, flash: { error: t('flash_messages.dashboard.label_not_found') }
  end

  class FetchLabelRequest
    def initialize(delivery, url)
      @delivery = delivery
      @url = url
    end

    def perform
      client.fetch_label @url
    end

    private

    def client
      @delivery.order.shipping_provider.api_client
    end
  end
end
