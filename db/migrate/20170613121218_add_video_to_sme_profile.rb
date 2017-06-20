class AddVideoToSmeProfile < ActiveRecord::Migration
  def self.up
    Instances::InstanceFinder.get(:uot).each do |instance|
      instance.set_context!

      video_ca = CustomAttributes::CustomAttribute.find_or_create_by(name: 'profile_video_url') do |record|
        record.attribute_type = "string"
        record.html_tag = "input"
        record.public = true
        record.label = "Profile Video URL (Facebook, Vimeo, YouTube videos):"
        record.target = InstanceProfileType.where(profile_type: 'buyer').first
        record.searchable = false
      end

      form_component = InstanceProfileType.where(profile_type: 'default').first.form_components.where(form_type: "instance_profile_types").first
      if form_component && form_component.form_fields.is_a?(Array)
        form_component.form_fields << { "buyer" => video_ca.name }
        form_component.save!

        FormComponentToFormConfiguration.new(PlatformContext.current.instance).go!
      end

      liquid_fragment = '
{% if user.has_buyer_profile? and user.buyer_properties.profile_video_url != blank %}
  <div class="profile-video">
    {{ user.buyer_properties.profile_video_url | videoify: width: 630, height: 354 }}
  </div>
{% endif %}
'

      iv = InstanceView.find_by(id: 3025)
      if iv.present?
        after_string = '<div class="content">'
        after_index = iv.body.index(after_string)
        if after_index.present? && iv.body.index('<div class="profile-video">').blank?
          iv.body.insert(after_index + after_string.length, "\n" + liquid_fragment + "\n")
          iv.save
        end
      end
    end
  end

  def self.down
    Instances::InstanceFinder.get(:uot).each do |instance|
      instance.set_context!

      CustomAttributes::CustomAttribute.find_by(name: 'profile_video_url').destroy

      form_component = InstanceProfileType.where(profile_type: 'default').first.form_components.where(form_type: "instance_profile_types").first
      if form_component && form_component.form_fields.is_a?(Array)
        form_component.form_fields.reject! { |ff| ff == { "buyer" => 'profile_video_url' } }
        form_component.save!

        FormComponentToFormConfiguration.new(PlatformContext.current.instance).go!
      end
    end
  end
end
