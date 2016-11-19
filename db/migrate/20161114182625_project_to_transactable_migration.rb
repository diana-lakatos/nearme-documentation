# frozen_string_literal: true
class ProjectToTransactableMigration < ActiveRecord::Migration
  def self.up
    MarketplaceError.reset_column_information
    TransactableType::ActionType.reset_column_information
    Order.reset_column_information
    Transactable.reset_column_information
    Location.reset_column_information
    Rake::Task['project_to_transactable:migrate_data'].invoke
  end

  def self.down
  end
end
