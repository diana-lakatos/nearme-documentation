class AddIsApprovalRequestSurfacingToFormComponents < ActiveRecord::Migration
  def change
    add_column :form_components, :is_approval_request_surfacing, :boolean, :default => false
  end
end
