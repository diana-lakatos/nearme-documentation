class MigrateProductTypeToTransactableType < ActiveRecord::Migration
  disable_ddl_transaction!
  def up
    Transactable.reset_column_information
    Rails.application.config.use_elastic_search = false
    Rake::Task['migrate_spree:to_action_types'].invoke
    Rails.application.config.use_elastic_search = true
  end
end
