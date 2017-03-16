# frozen_string_literal: true
class AddTimestampsToLinks < ActiveRecord::Migration
  def change
    add_column(:links, :created_at, :datetime)
    add_column(:links, :updated_at, :datetime)
  end
end
