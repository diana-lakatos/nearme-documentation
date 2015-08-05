class InstanceAdmin::Manage::ServiceTypes::CustomAttributesController < InstanceAdmin::Manage::CustomAttributesController

  before_filter :set_breadcrumbs_title

  protected

  def redirection_path
    instance_admin_manage_service_type_custom_attributes_path(@target)
  end

  def find_target
    @target = ServiceType.find(params[:service_type_id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_service_types_path, :title => t('instance_admin.manage.service_types.service_types') },
      { :title => t('instance_admin.manage.service_types.custom_attributes') }
    )
  end

end
