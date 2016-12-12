namespace :hallmark do
  desc 'Setup hallmark'

  task groups: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!

    %w(Public Moderated Private).each do |name|
      group_type = GroupType.where(name: name).first_or_create!

      group_type.custom_validators.where(field_name: 'name').first_or_initialize.tap do |cv|
        cv.max_length = 140
      end.save!

      group_type.custom_validators.where(field_name: 'description').first_or_initialize.tap do |cv|
        cv.max_length = 5000
      end.save!

      group_type.custom_attributes.where(name: 'videos').first_or_initialize.tap do |ca|
        ca.public = true
        ca.html_tag = 'input'
        ca.attribute_type = 'array'
        ca.label = 'Videos'
        ca.hint = 'Enter URL to Youtube or Vimeo video'
        ca.public = true
        ca.searchable = false
      end.save!
    end
  end

  task setup: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!

    WorkflowAlert
      .find_by(instance_id: instance.id, name: 'Member approved email')
      .try(:update_columns,         name: 'Notify user of approved join request',
                                    template_path: 'group_mailer/notify_user_of_approved_join_request')

    Workflow.find_by(instance_id: instance.id, workflow_type: 'group_workflow').workflow_steps.each do |step|
      step.workflow_alerts.where(alert_type: 'email').each do |alert|
        alert.update!(
          from: 'from@hallmark.com',
          reply_to: 'replyto@hallmark.com'
        )
      end
    end

    Utils::DefaultAlertsCreator::GroupCreator.new.create_all!
    Utils::DefaultAlertsCreator::CollaboratorCreator.new.create_all!
    Utils::DefaultAlertsCreator::UserCreator.new.create_user_promoted_email!
    Utils::DefaultAlertsCreator::FollowerCreator.new.create_all!
    Utils::DefaultAlertsCreator::CommenterCreator.new.create_all!

    Rails.cache.clear
  end
end
