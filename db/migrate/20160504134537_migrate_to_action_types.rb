class MigrateToActionTypes < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    Rails.application.config.use_elastic_search = false
    Rake::Task['migrate:to_action_types'].invoke
    Rails.application.config.use_elastic_search = true
  end
end
