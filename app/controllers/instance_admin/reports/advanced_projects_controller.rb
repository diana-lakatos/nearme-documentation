class InstanceAdmin::Reports::AdvancedProjectsController < InstanceAdmin::Reports::BaseController

  before_filter :set_breadcrumbs_title

  def index
  end

  def download_report
    project_infos = CommunityAdvancedReportsGenerator.new(params).search

    csv = CSV.generate do |csv|
      csv << CommunityAdvancedReportsGenerator::COLUMNS.values

      project_infos.each do |project_info|
        csv << project_info
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

  def set_breadcrumbs_title
    @breadcrumbs_title = BreadcrumbsList.new(
      { :title => t('instance_admin.general.reports') },
      { :title => t('instance_admin.reports.advanced_projects.community_reports'), :url => instance_admin_reports_projects_path }
    )
  end

end

