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
    prepare_view_object
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
    prepare_view_object
    resource.update_attributes provider_params
  end

  def collection
    @providers = @instance.shipping_providers
  end

  def prepare_view_object
    @view = OpenStruct.new(
      provider: Deliveries::Provider.find(resource.shipping_provider_name),
      resource: resource
    )
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
    def self.perform(provider)
      new(provider).perform
    end

    def initialize(provider)
      @provider = provider
    end

    def perform
      return if already_imported?

      client.predefined_packages.each do |package|
        import package.attributes
      end
    end

    private

    def already_imported?
      @provider.dimensions_templates.any?
    end

    def import(attributes)
      @provider.dimensions_templates.create! attributes
    end

    # TODO: load settings based on env
    # TODO: make it injectable [DI/IoC]
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
