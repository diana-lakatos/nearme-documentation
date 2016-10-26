class InstanceAdmin::Reports::ListingsController < InstanceAdmin::Reports::BaseController
  include ReportsProperties

  before_action :set_breadcrumbs_title
  before_action :find_transactable, only: [:edit, :update, :show, :destroy]

  def index
    @transactable_search_form = InstanceAdmin::TransactableSearchForm.new
    @transactable_search_form.validate(params)
    @transactables = SearchService.new(Transactable.order('created_at DESC')).search(@transactable_search_form.to_search_params).paginate(page: params[:page])
  end

  def edit; end

  def update
    @transactable_type = @transactable.transactable_type

    if @transactable.update_attributes(transactable_params)
      flash[:success] = t('flash_messages.instance_admin.reports.listings.successfully_updated')

      redirect_to edit_instance_admin_reports_listing_path(@transactable)
    else
      render 'edit'
    end
  end

  def destroy
    TransactableDestroyerService.new(@transactable).destroy

    flash[:deleted] = t('flash_messages.instance_admin.reports.listings.successfully_deleted')
    redirect_to instance_admin_reports_listings_path
  end

  def download_report
    @transactable_search_form = InstanceAdmin::TransactableSearchForm.new
    @transactable_search_form.validate(params)
    @transactables = SearchService.new(Transactable.order('created_at ASC')).search(@transactable_search_form.to_search_params)
    @transactable_type = TransactableType.find_by(id: params[:item_type_id])

    csv = export_data_to_csv_for_transactables(@transactables, @transactable_type)

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

  def show
    append_to_breadcrumbs(t('instance_admin.general.listing'))
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { title: t('instance_admin.general.reports') },
      title: t('instance_admin.general.listings'), url: instance_admin_reports_listings_path
    )
  end

  def transactable_params
    params.require(:transactable).permit(secured_params.transactable(@transactable_type))
  end

  def find_transactable
    @transactable = Transactable.find(params[:id])
  end
end
