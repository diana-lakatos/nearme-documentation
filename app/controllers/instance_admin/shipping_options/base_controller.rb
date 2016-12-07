# frozen_string_literal: true
module InstanceAdmin::ShippingOptions
  class BaseController < InstanceAdmin::BaseController
    def index
      redirect_to instance_admin_shipping_options_dimensions_templates
    end

    protected

    def permitting_controller_class
      'Settings'
    end
  end
end
