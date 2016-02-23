class AddDraftAtToApprovalRequests < ActiveRecord::Migration
  def change
    add_column :approval_requests, :draft_at, :timestamp
    Instance.find_each do |instance|
      ApprovalRequest.pending.where(owner_type: 'Transactable', draft_at: nil).find_each do |ar|
        if ar.owner.draft
          ar.update_column :draft_at, ar.owner.draft
        end
      end
    end
  end
end
