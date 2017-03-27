class InstanceAdmin::Reports::BaseController < InstanceAdmin::BaseController
  include ReportsProperties

  before_filter :set_scopes, :set_breadcrumbs_title

  def index
    @scope_search_form = @search_form.new
    @scope_search_form.validate(params)
    scope = @scope_class.order("#{@scope_class.table_name}.created_at DESC")
    @resources = SearchService.new(scope).search(@scope_search_form.to_search_params).paginate(page: params[:page], per_page: reports_per_page)
 end

  def download_report
    @scope_search_form = @search_form.new
    @scope_search_form.validate(params)
    @scope_class = @scope_class.includes(location: :location_address) if @scope_class == Transactable
    @resources = SearchService.new(@scope_class.order(created_at: 'ASC')).search(@scope_search_form.to_search_params)
    @scope_type = @scope_type_class.find_by_id(params[:item_type_id])

    csv = export_data_to_csv_for(@resources)

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

  def edit
    @resource = @scope_class.with_deleted.find(params[:id])
  end

  def update
    @resource = @scope_class.with_deleted.find(params[:id])
    if @resource.update_attributes(transactable_params)
      flash[:success] = t('flash_messages.instance_admin.reports.listings.successfully_updated')

      redirect_to [:edit, :instance_admin, :reports, @resource]
    else
      render 'edit'
    end
  end

  def show
    append_to_breadcrumbs(t("instance_admin.general.#{@scope_class.name.downcase.singularize}"))
    @resource = @scope_class.with_deleted.find(params[:id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { title: t('instance_admin.general.reports') },
      title: t("instance_admin.general.#{@scope_class.name.tableize}"), url: polymorphic_path([:instance_admin, :reports, @scope_class])
    )
  end
end
