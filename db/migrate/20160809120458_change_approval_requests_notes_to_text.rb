class ChangeApprovalRequestsNotesToText < ActiveRecord::Migration
  def up
    change_column :approval_requests, :notes, :text
  end

  def down
    change_column :approval_requests, :notes, :string
  end
end
