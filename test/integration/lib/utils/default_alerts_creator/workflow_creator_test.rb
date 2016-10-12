require 'test_helper'

class Utils::DefaultAlertsCreator::WorkflowCreatorTest < ActionDispatch::IntegrationTest
  class DummyCreator < Utils::DefaultAlertsCreator::WorkflowCreator
    def create_dummy_alert
      create_alert!(associated_class: WorkflowStep::ListingWorkflow::Created, name: 'name', path: 'some/path', subject: 'subject', alert_type: 'email', recipient_type: 'lister')
    end

    def workflow_type
      'dummy_type'
    end
  end

  setup do
    @dummy_creator = DummyCreator.new
    PlatformContext.current.theme.update_attribute(:contact_email, 'some_email@example.com')
  end

  should 'populate from and reply_to with contact_email as default' do
    assert_difference 'WorkflowAlert.count' do
      @workflow_alert = @dummy_creator.create_dummy_alert
    end
    assert_equal 'some_email@example.com', @workflow_alert.from
    assert_equal 'some_email@example.com', @workflow_alert.reply_to
  end
end
