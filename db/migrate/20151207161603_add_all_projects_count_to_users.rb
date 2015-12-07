class AddAllProjectsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :projects_count, :integer, null: false, default: 0
    add_column :users, :project_collborations_count, :integer, null: false, default: 0

    User.find_each do |u|
      u.projects_count = Project.where(creator_id: u.id).enabled.count
      u.project_collborations_count = u.approved_project_collaborations.count
      u.save(validate: false)
    end
  end
end
