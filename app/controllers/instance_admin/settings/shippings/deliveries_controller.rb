# frozen_string_literal: true
class InstanceAdmin::Settings::Shippings::DeliveriesController < InstanceAdmin::Settings::BaseController
  helper_method :collection
  respond_to :html, :json

  def index
    respond_with collection
  end

  def show
  end

  def destroy
    # TODO: implement
    respond_with :instance_admin, :settings, :shippings, :shipping_providers
  end

  private

  def resource
    @resource ||= collection.find(params[:id])
  end

  def collection
    @providers ||= Delivery
                     .order('id desc')
                     .paginate(page: params[:page], per_page: 10)
  end

  class DestroyDeliveryOrder
    def initialize(provider:)
      @provider = provider
    end

    def client
      Deliveries.courier name: @provider.shipping_provider_name,
                         settings: @provider.settings
    end
  end

  protected

  def permitting_controller_class
    'Settings'
  end
end
