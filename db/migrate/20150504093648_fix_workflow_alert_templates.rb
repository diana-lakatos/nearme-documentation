class FixWorkflowAlertTemplates < ActiveRecord::Migration
  def change
    WorkflowStep.where(name: 'One Day To Booking').find_each do |ws|
      ws.workflow_alerts.where(template_path: 'reservation_mailer/notify_guest_of_payment_request').update_all(template_path: 'reservation_mailer/pre_booking')
    end
  end
end
