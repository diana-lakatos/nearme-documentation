class InstanceAdmin::BuySell::ProductTypes::DataUploadsController < InstanceAdmin::DataUploads::BaseController


  private

  def set_import_job
    @import_job = DataUploadProductImportJob
  end

  def permitting_controller_class
    'buy_sell'
  end

  def find_importable
    @importable = Spree::ProductType.find(params[:product_type_id])
  end
end
