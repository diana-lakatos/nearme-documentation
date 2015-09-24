class AddPolymorphicBelongsToToDimensionsTemplates < ActiveRecord::Migration
  def self.up
    add_column :dimensions_templates, :entity_id, :integer, :null => true
    add_column :dimensions_templates, :entity_type, :string, :null => true

    DimensionsTemplate.all.each do |dt|
      dt.entity = dt.instance
      dt.save!
    end
  end

  def self.down
    remove_column :dimensions_templates, :entity_id
    remove_column :dimensions_templates, :entity_type
  end
end
