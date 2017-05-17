class PrefixUploadableCustomAttributeNamesToAvoidConflicts < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instance.all.each do |instance|
        instance.set_context!
        CustomAttributes::CustomAttribute.all.select {|ca| !ca.valid? && ca.errors.include?(:name) }.each do |invalid_ca|
          puts "Adding prefix to: #{invalid_ca.target.name}.#{invalid_ca.name}"
          invalid_ca.name = "#{invalid_ca.target.name.downcase.singularize}_#{invalid_ca.name}"
          invalid_ca.save!
        end
      end
    end
  end

  def down
  end
end
