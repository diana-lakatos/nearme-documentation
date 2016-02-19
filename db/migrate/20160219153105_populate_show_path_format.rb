class PopulateShowPathFormat < ActiveRecord::Migration
  def up
    ServiceType.reset_column_information
    ServiceType.where(show_path_format: nil).find_each do |st|
      st.update_attribute(:show_path_format, st.show_page_enabled? ? "/locations/:location_id/listings/:id" : "/locations/:location_id/:id")
    end
  end

  def down
  end
end
