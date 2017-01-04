class Dashboard::PackageLabelsController < ApplicationController
  def show
    return handle_label_not_found if label.nil?

    redirect_to label.url
  end

  private

  def delivery
    @delivery ||= Delivery.find(params[:delivery_id])
  end

  def label
    Array(delivery.labels).find { |label| label['size'] == params[:id] }
  end

  def handle_label_not_found
    SyncDeliveryStateJob.perform(delivery.order_id)
    redirect_to :back, flash: { error: t('flash_messages.dashboard.label_not_found') }
  end
end
