# frozen_string_literal: true
class AddDeepLevelToPage < ActiveRecord::Migration
  def change
    add_column :pages, :max_deep_level, :integer, default: 3
  end
end
