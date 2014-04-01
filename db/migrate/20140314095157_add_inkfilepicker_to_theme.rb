class AddInkfilepickerToTheme < ActiveRecord::Migration
  def up
    
    %w(icon_image icon_retina_image favicon_image logo_image logo_retina_image hero_image).each do |img|
      add_column :themes, :"#{img}_transformation_data", :text
      add_column :themes, :"#{img}_original_url", :string
      add_column :themes, :"#{img}_versions_generated_at", :datetime, :default => nil
      add_column :themes, :"#{img}_original_width", :integer, :default => nil
      add_column :themes, :"#{img}_original_height", :integer, :default => nil
      Theme.all.each do |t|
        t.update_column(:"#{img}_versions_generated_at", t.send(img).url.present? ? Time.zone.now : nil)
      end
    end
  end

  def down
    %w(icon_image icon_retina_image favicon_image logo_image logo_retina_image hero_image).each do |img|
      remove_column :themes, :"#{img}_transformation_data"
      remove_column :themes, :"#{img}_original_url"
      remove_column :themes, :"#{img}_versions_generated_at"
      remove_column :themes, :"#{img}_original_width"
      remove_column :themes, :"#{img}_original_height"
    end
  end

end
