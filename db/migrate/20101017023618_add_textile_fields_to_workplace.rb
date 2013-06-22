class AddTextileFieldsToWorkplace < ActiveRecord::Migration
  def self.up
    add_column :workplaces, :description_html, :text
    add_column :workplaces, :company_description_html, :text

    # Workplace.all.each do |wp|
    #       wp.send :apply_filter
    #       wp.save
    #     end
  end

  def self.down
    remove_column :workplaces, :company_description_html
    remove_column :workplaces, :description_html
  end
end
