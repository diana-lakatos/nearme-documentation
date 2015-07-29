module CheckoutExtraFieldsHelper

  def ensure_required_custom_attribute_is_present
    instance = Instance.unscoped.first
    i = instance.instance_profile_type
    i = InstanceProfileType.create!(instance_id: instance.id) unless i
    i.custom_attributes << FactoryGirl.create(:custom_attibute_license, target: i)
  end

end

World(CheckoutExtraFieldsHelper)
