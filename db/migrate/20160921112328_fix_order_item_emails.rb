class FixOrderItemEmails < ActiveRecord::Migration
  def self.up
    WorkflowAlert.where(name: 'notify_enquirer_rejected_order_item'.humanize).each do |workflow_alert|
      workflow_alert.recipient_type = 'enquirer'
      workflow_alert.save
    end

    WorkflowAlert.where(name: 'notify_enquirer_approved_order_item'.humanize).each do |workflow_alert|
      workflow_alert.recipient_type = 'enquirer'
      workflow_alert.save
    end
  end
end
