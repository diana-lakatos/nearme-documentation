class InstanceAdmin::Reports::ProjectsController < InstanceAdmin::Reports::BaseController

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

  private

  def set_scopes
    @scope_type_class = ProjectType
    @scope_class = Project
  end

end

