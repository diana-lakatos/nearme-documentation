# frozen_string_literal: true
class PopulateFormConfigurations < ActiveRecord::Migration
  def up
    Rake::Task['migrate:form_configuration'].execute
  end

  def down
  end
end
