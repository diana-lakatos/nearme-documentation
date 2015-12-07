class CommunityAggregatesCreationService

  def initialize
  end

  def create_aggregates
    Instance.find_each do |i|
      next if !i.is_community?
      puts "-> Working on instance: #{i.domains.first.name}"

      i.set_context!

      last_report = CommunityReportingAggregate.order('created_at DESC').first
      if last_report.blank?
        start_date, end_date = CommunityReportingAggregate.get_oldest_reporting_period
      else
        start_date, end_date = last_report.get_next_reporting_period
      end

      loop do
        if end_date > Time.now
          puts "Skipped for #{start_date} - #{end_date}"
          break
        end

        puts "Creating CommunityReportingAggregate for #{start_date} - #{end_date}"
        current_report = CommunityReportingAggregate.new
        current_report.start_date = start_date
        current_report.end_date = end_date
        current_report.update_all_statistics
        current_report.save!

        start_date, end_date = current_report.get_next_reporting_period
      end
    end
  end

end
