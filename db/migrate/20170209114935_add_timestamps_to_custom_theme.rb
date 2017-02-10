class AddTimestampsToCustomTheme < ActiveRecord::Migration
  def change
    change_table :custom_themes do |t|
      t.timestamps
    end

    CustomTheme.all.each {|t| t.touch(:created_at, :updated_at) }
  end
end
