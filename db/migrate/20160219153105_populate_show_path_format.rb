class PopulateShowPathFormat < ActiveRecord::Migration
  def up
    TransactableType.reset_column_information
    TransactableType.where(show_path_format: nil).find_each do |st|
      st.update_attribute(:show_path_format, st.show_page_enabled? ? "/locations/:location_id/listings/:id" : "/locations/:location_id/:id")
    end
  end

  def down
  end
end
