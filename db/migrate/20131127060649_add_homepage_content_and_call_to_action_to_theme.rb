class AddHomepageContentAndCallToActionToTheme < ActiveRecord::Migration
  def change
    add_column :themes, :homepage_content, :text
    add_column :themes, :call_to_action, :string
  end
end
