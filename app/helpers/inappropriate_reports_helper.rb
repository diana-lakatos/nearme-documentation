# frozen_string_literal: true
module InappropriateReportsHelper

  def inappropriate_report_target_link(report)
    case report.reportable_type
    when 'User'
      link_to 'User', profile_path(report.reportable.slug)
    when 'Transactable'
      link_to 'Transactable', report.reportable.decorate.show_path
    end
  end

end
