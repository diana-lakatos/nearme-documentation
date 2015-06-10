class AddDraftAtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :draft_at, :datetime, default: nil
  end
end
