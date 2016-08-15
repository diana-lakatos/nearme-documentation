class ProjectToTransactableMigration < ActiveRecord::Migration
  def self.up
    Rake::Task['project_to_transactable:migrate_data'].invoke
  end

  def self.down
  end
end
