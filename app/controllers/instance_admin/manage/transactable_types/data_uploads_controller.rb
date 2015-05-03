class InstanceAdmin::Manage::TransactableTypes::DataUploadsController < InstanceAdmin::DataUploads::BaseController

  before_filter :set_breadcrumbs_title

  private

  def set_import_job
    @import_job = DataUploadConvertJob
  end

  def permitting_controller_class
    'manage'
  end

  def find_importable
    @importable = TransactableType.find(params[:transactable_type_id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = 'Service Types'
  end
end
