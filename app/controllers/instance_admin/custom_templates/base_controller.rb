class InstanceAdmin::CustomTemplates::BaseController < InstanceAdmin::ResourceController

  def index
    redirect_to instance_admin_custom_templates_custom_themes_path
  end

  def permitting_controller_class
    'customtemplates'
  end

end

