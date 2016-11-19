# frozen_string_literal: true
class InstanceAdmin::Settings::Shippings::ShippingProvidersController < InstanceAdmin::Settings::BaseController
  respond_to :html

  after_action :create_default_parcels, only: :update

  def index
    respond_with collection
  end

  def show
    redirect_to [:instance_admin, :settings, :shippings, :shipping_providers]
  end

  def new
    respond_with build_resource
  end

  def edit
    @view = OpenStruct.new(
      provider: Shippings::Provider.find(resource.shipping_provider_name),
      resource: resource
    )
    respond_with @view
  end

  def create
    create_resource
    respond_with :instance_admin, :settings, resource
  end

  def update
    update_resource
    respond_with :instance_admin, :settings, resource
  end

  def destroy
    resource.destroy
    respond_with :instance_admin, :settings, :shippings, :shipping_providers
  end

  private

  def resource
    @resource ||= collection.find(params[:id])
  end

  def build_resource
    @resource = collection.build
  end

  def create_resource
    @resource = collection.create provider_params
  end

  def update_resource
    resource.update_attributes provider_params
  end

  def collection
    @providers = @instance.shipping_providers
  end

  def provider_params
    params
      .require(:shippings_shipping_provider)
      .permit(secured_params.shipping_provider)
  end

  def create_default_parcels
    CreateDefaultParcels.perform(resource)
  end

  class CreateDefaultParcels
    def self.perform(resource)
      new(resource).perform
    end

    def initialize(resource)
      @resource = resource
    end

    def perform
      client.predefined_packages.each do |package|
        import package.attributes
      end
    end

    private

    def import(attributes)
      @resource.dimensions_templates.create! attributes
    end

    # TODO: load settings based on env
    # TODO: make it injectable [DI/IoC]
    def client
      Deliveries.courier name: @resource.shipping_provider_name,
                         settings: @resource.test_settings
    end
  end
end
