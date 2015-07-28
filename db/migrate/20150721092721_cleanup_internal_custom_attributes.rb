class CleanupInternalCustomAttributes < ActiveRecord::Migration
  def up
    Instance.find_each do |instance|
      puts "Processing #{instance.name}"
      instance.set_context!
      CustomAttributes::CustomAttribute.where.not(name: 'listing_type').where(internal: true).each do |ca|
        puts "\tDeleting CustomAttribute: #{ca.name}"
        ca.destroy
      end
    end
    remove_column :custom_attributes, :internal
  end

  def down
    add_column :custom_attributes, :internal, :boolean
  end
end
