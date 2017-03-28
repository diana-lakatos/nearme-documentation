class FixLocaldrivaConditionField < ActiveRecord::Migration
  def up
    instance = Instance.find_by(211)
    return unless instance.present?
    instance.set_context!
    ca = CustomAttributes::CustomAttribute.where(name: 'driver_category').first
    condition_field = ca.wrapper_html_options['data-condition-field'].gsub('user_buyer_profile_attributes_properties', 'user_profiles_attributes_buyer_attributes_properties')
    ca.wrapper_html_options['data-condition-field'] = condition_field
    ca.update_column(:wrapper_html_options, ca.wrapper_html_options)
  end

  def down
  end
end
