module InstanceAdmin::ShippingOptions
  class BaseController < InstanceAdmin::BaseController
    def index
      redirect_to instance_admin_shipping_options_dimensions_templates
    end
  end
end
