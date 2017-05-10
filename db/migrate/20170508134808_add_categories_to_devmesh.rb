class AddCategoriesToDevmesh < ActiveRecord::Migration
  def self.up
    Instances::InstanceFinder.get(:devmesh).each do |intel_instance|
      intel_instance.set_context!

      c = Category.where(instance: intel_instance, name: 'Categories',
                         parent_id: nil).first_or_create! do |c|
        c.multiple_root_categories = true
        c.instance_profile_type_ids = [InstanceProfileType.where(profile_type: 'default').first.id]
      end

      ['Student Developer', 'Professional Developer', 'Hobbyist',
       'Enthusiast', 'Designer', 'Mobile Developer', 'C#',
       'Javascript', 'Python'].each do |subcategory_name|
         # We don't use first_or_create due to issue with setting permalink
         subcategory = Category.where(parent: c, name: subcategory_name).first
         Category.create!(parent: c, name: subcategory_name) if subcategory.blank?
       end

      form_configuration = FormConfiguration.where(name: 'default_update').first
      form_configuration.configuration[:profiles][:default][:categories] = { 'Categories' => 
                                                                             { 'validation' => { } } }
      form_configuration.save!
    end
  end

  def self.down
    Instances::InstanceFinder.get(:devmesh).each do |intel_instance|
      intel_instance.set_context!

      c = Category.where(instance: intel_instance, name: 'Categories',
                         parent_id: nil).first
      c.destroy if c.present?

      form_configuration = FormConfiguration.where(name: 'default_update').first
      form_configuration.configuration[:profiles][:default].delete(:categories)
      form_configuration.save!
    end
  end
end
