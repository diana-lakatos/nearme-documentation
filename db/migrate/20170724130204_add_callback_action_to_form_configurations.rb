class AddCallbackActionToFormConfigurations < ActiveRecord::Migration
  def change
    add_column :form_configurations, :callback_actions, :text
  end
end
