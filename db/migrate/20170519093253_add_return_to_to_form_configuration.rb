class AddReturnToToFormConfiguration < ActiveRecord::Migration
  def change
    add_column :form_configurations, :return_to, :text
  end
end
