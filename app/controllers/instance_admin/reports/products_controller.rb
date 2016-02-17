class InstanceAdmin::Reports::ProductsController < InstanceAdmin::Reports::BaseController

  def show
    append_to_breadcrumbs(t('instance_admin.general.product'))
    @resource = Spree::Product.find(params[:id])
  end

  def destroy
    @resource = Spree::Product.find(params[:id])
    @resource.destroy
    flash[:deleted] = t('flash_messages.instance_admin.reports.listings.successfully_deleted')

    redirect_to instance_admin_reports_products_path
  end

  private

  def set_scopes
    @scope_type_class = Spree::ProductType
    @scope_class = Spree::Product
    @search_form = InstanceAdmin::ProductSearchForm
  end
end

