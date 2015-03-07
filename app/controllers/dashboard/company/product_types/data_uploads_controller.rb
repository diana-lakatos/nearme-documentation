class Dashboard::Company::ProductTypes::DataUploadsController < Dashboard::DataUploads::BaseController

  def download_current_data_csv
    raise NotImplementedError
  end

  private

  def set_import_job
    @import_job = DataUploadProductHostImportJob
  end

  def find_importable
    @importable = Spree::ProductType.find(params[:product_type_id])
  end

  def after_import_redirect_path
    dashboard_company_product_type_products_path(@importable)
  end

end

