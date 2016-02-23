class InstanceAdmin::Manage::ServiceTypes::DataUploadsController < InstanceAdmin::DataUploads::BaseController

  before_filter :set_breadcrumbs_title

  private

  def set_import_job
    @import_job = DataUploadConvertJob
  end

  def permitting_controller_class
    'manage'
  end

  def find_importable
    @importable = ServiceType.find(params[:service_type_id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :url => instance_admin_manage_service_types_path, :title => t('instance_admin.manage.service_types.service_types') },
      { :title => t('instance_admin.manage.service_types.data_upload') }
    )
  end
end
