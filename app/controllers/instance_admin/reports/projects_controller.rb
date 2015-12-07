class InstanceAdmin::Reports::ProjectsController < InstanceAdmin::Reports::BaseController

  before_filter :set_breadcrumbs_title

  def index
  end

  def download_report
    aggregates = CommunityAggregatesSearcher.new(params).search

    csv = CSV.generate do |csv|
      csv << ['Date Start', 'Date End', CommunityReportingAggregate::COLUMNS.values].flatten

      aggregates.each do |aggregate|
        csv << aggregate.get_values_for_record
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

  def show
    append_to_breadcrumbs(t('instance_admin.general.product'))
    @product = Spree::Product.find(params[:id])
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :title => t('instance_admin.general.reports') },
      { :title => t('instance_admin.general.projects'), :url => instance_admin_reports_projects_path }
    )
  end

end

