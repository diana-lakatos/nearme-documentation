class InstanceAdmin::Reports::ProductsController < InstanceAdmin::Reports::BaseController
  include ReportsProperties

  before_filter :set_breadcrumbs_title
  before_filter :find_product, only: [:show, :edit, :update, :destroy]

  def index
    @product_search_form = InstanceAdmin::ProductSearchForm.new
    @product_search_form.validate(params)
    @products = SearchService.new(Spree::Product.order('created_at DESC')).search(@product_search_form.to_search_params).paginate(page: params[:page])
  end

  def show
    append_to_breadcrumbs(t('instance_admin.general.product'))
    @resource = Spree::Product.find(params[:id])
  end

  def edit; end

  def update
    if @product.update_attributes(product_params)
      flash[:success] = t('flash_messages.instance_admin.reports.products.successfully_updated')

      redirect_to edit_instance_admin_reports_product_path(@product)
    else
      render 'edit'
    end
  end

  def destroy
    @product.destroy
    flash[:deleted] = t('flash_messages.instance_admin.reports.listings.successfully_deleted')

    redirect_to instance_admin_reports_products_path
  end

  def edit; end

  def update
    if @product.update_attributes(product_params)
      flash[:success] = t('flash_messages.instance_admin.reports.products.successfully_updated')

      redirect_to edit_instance_admin_reports_product_path(@product)
    else
      render 'edit'
    end
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

  private
    def set_breadcrumbs_title
      @breadcrumbs_title = BreadcrumbsList.new(
        { :title => t('instance_admin.general.reports') },
        { :title => t('instance_admin.general.products'), :url => instance_admin_reports_products_path }
      )
    end

    def find_product
      @product = Spree::Product.where("id = :slug OR slug = :slug", slug: params[:id]).first!
    end

    def product_params
      params.require(:product).permit(secured_params.spree_product)
    end
end
