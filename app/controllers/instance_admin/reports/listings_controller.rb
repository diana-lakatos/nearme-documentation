class InstanceAdmin::Reports::ListingsController < InstanceAdmin::Reports::BaseController

  include ReportsProperties

  before_filter :set_breadcrumbs_title

  def index
    @transactable_search_form = InstanceAdmin::TransactableSearchForm.new
    @transactable_search_form.validate(params)
    @transactables = SearchService.new(Transactable.order('created_at DESC')).search(@transactable_search_form.to_search_params).paginate(page: params[:page])
  end

  def download_report
    @transactable_search_form = InstanceAdmin::TransactableSearchForm.new
    @transactable_search_form.validate(params)
    @transactables = SearchService.new(Transactable.order('created_at ASC')).search(@transactable_search_form.to_search_params)
    @transactable_type = TransactableType.find_by_id(params[:item_type_id])

    csv = export_data_to_csv_for_transactables(@transactables, @transactable_type)

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

  def show
    append_to_breadcrumbs(t('instance_admin.general.listing'))
    @transactable = Transactable.find(params[:id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :title => t('instance_admin.general.reports') },
      { :title => t('instance_admin.general.listings'), :url => instance_admin_reports_listings_path }
    )
  end
end

