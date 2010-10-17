class AddUrlToWorkplace < ActiveRecord::Migration
  def self.up
    add_column :workplaces, :url, :text
  end

  def self.down
  end
end
