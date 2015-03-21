class RemoveOriginalUrls < ActiveRecord::Migration
  def change
    %w(icon icon_retina favicon logo logo_retina hero).each do |attr|
      remove_column :themes, "#{attr}_image_original_url"
    end
    remove_column :users, :avatar_original_url
  end
end
