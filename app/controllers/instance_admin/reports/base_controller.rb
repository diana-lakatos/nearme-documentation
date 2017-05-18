class InstanceAdmin::Reports::BaseController < InstanceAdmin::BaseController
  before_filter :set_scopes, :set_breadcrumbs_title

  def index
    @scope_search_form = @search_form.new
    @scope_search_form.validate(params)
    scope = @scope_class.order("#{@scope_class.table_name}.created_at DESC")
    @resources = SearchService.new(scope).search(@scope_search_form.to_search_params).paginate(page: params[:page], per_page: reports_per_page)
    @generated_reports = MarketplaceReport.where(report_type: @scope_class.to_s).order('created_at DESC').paginate(page: params[:generated_page], per_page: 10)
 end

  def request_report_generation 
    @scope_search_form = @search_form.new
    @scope_search_form.validate(params)
    
    marketplace_report = MarketplaceReport.create(report_type: @scope_class.to_s,
                                                  creator: current_user,
                                                  report_parameters: @scope_search_form.to_search_params)

    MarketplaceReportsCreatorJob.perform(marketplace_report.id)

    flash[:notice] = t('instance_admin.reports.generated.notifications.please_wait_for_report_generation')

    redirect_to :back
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
