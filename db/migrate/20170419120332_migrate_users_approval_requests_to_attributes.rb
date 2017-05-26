class MigrateUsersApprovalRequestsToAttributes < ActiveRecord::Migration
  def self.up
    Instance.find_each do |instance|
      instance.set_context!

      art = ApprovalRequestTemplate.where(owner_type: 'User').first
      if art.present?
        ipt = InstanceProfileType.where(profile_type: 'default').first
        if ipt.present?
          ipt.update_column(:admin_approval, true)

          art.approval_request_attachment_templates.each do |arat|
            ca = CustomAttributes::CustomAttribute.new
            ca.name = "approval_attachment_#{arat.id}"
            ca.attribute_type = "file"
            ca.html_tag = "input"
            ca.public = true
            ca.label = arat.label
            ca.hint = arat.hint
            ca.target = ipt
            ca.validation_only_on_update = true
            ca.prompt = ''
            ca.default_value = ''
            ca.placeholder = ''
            ca.save!

            if arat.required
              cv = CustomValidator.new
              cv.validatable = ca
              cv.field_name = ca.name
              cv.required = true
              cv.validation_only_on_update = true
              cv.save!
            end

            form_component = ipt.form_components.where(form_type: "instance_profile_types").first
            if form_component && form_component.form_fields.is_a?(Array)
              form_component.form_fields << {"user" => ca.name}
              form_component.save!

              FormComponentToFormConfiguration.new(PlatformContext.current.instance).go!
            end
          end
        end

        ApprovalRequest.where(approval_request_template: art).find_each do |ar|
          if ar.approved? && ar.owner.try(:default_profile).present?
            ar.owner.default_profile.update_attribute(:approved, true)
          end

          ar.approval_request_attachments.each do |ara|
            custom_attachment = CustomAttachment.new
            custom_attachment.custom_attribute = CustomAttributes::CustomAttribute.find_by(name: "approval_attachment_#{ara.approval_request_attachment_template.id}")
            custom_attachment.owner = ar.owner.try(:default_profile)
            custom_attachment.uploader = ar.owner
            custom_attachment.remote_file_url = ara.file.url
            if !custom_attachment.save
              Rails.logger.warn("Could not save custom attachment for approval request template #{art.id}, "\
                                "approval request #{ar.id}, approval request attachment #{ara.id}")
            end
          end
        end
      end
    end
  end

  def self.down
  end
end
