class UpdateWorkflowAlertsForCommunity < ActiveRecord::Migration
  def up
    Instance.where(is_community: true).find_each do |instance|
      instance.set_context!

      alert = WorkflowAlert.where(name: 'Member approved email').first

      if alert.present?
        alert.update_columns(
          name: 'Notify user of approved join request',
          template_path: 'group_mailer/notify_user_of_approved_join_request'
        )
      end

      Utils::DefaultAlertsCreator::GroupCreator.new.create_all!
      Utils::DefaultAlertsCreator::ActivityEventsSummaryCreator.new.create_all!
      Utils::DefaultAlertsCreator::CommenterCreator.new.create_all!
    end
  end
end
