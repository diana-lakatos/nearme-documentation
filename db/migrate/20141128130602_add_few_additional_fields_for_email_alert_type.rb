class AddFewAdditionalFieldsForEmailAlertType < ActiveRecord::Migration
  def change
    add_column :workflow_alerts, :from, :string
    add_column :workflow_alerts, :reply_to, :string
    add_column :workflow_alerts, :cc, :string
    add_column :workflow_alerts, :bcc, :string
  end
end
