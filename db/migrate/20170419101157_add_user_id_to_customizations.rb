# frozen_string_literal: true
class AddUserIdToCustomizations < ActiveRecord::Migration
  def change
    add_column :customizations, :user_id, :integer
  end
end
