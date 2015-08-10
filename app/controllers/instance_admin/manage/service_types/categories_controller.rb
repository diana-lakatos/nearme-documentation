class InstanceAdmin::Manage::ServiceTypes::CategoriesController < InstanceAdmin::CategoriesController

  before_filter :set_breadcrumbs_title

  private

  def find_categorizable
    @categorizable = ServiceType.find(params[:service_type_id])
  end

  def permitting_controller_class
    @controller_scope ||= 'manage'
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_service_types_path, :title => t('instance_admin.manage.service_types.service_types') },
      { :url => instance_admin_manage_service_type_categories_path, :title => t('instance_admin.manage.service_types.categories') }
    )
  end
end
