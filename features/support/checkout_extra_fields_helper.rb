module CheckoutExtraFieldsHelper

  def ensure_required_custom_attribute_is_present
    instance = Instance.unscoped.first
    i = instance.instance_profile_type
    i = InstanceProfileType.create!(instance_id: instance.id) unless i
    i.custom_attributes.create!({
      name: 'license_number', attribute_type: 'string', html_tag: 'input',
      required: '1', public: '1',
      label: 'License number',
      valid_values: []
    })
    attribute = i.custom_attributes.first
    attribute.validation_rules = { :presence => {} }
    attribute.save
  end

end

World(CheckoutExtraFieldsHelper)
