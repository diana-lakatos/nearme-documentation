require 'test_helper'

class Utils::DefaultAlertsCreator::InstanceAlertsCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @instance_creator = Utils::DefaultAlertsCreator::InstanceAlertsCreator.new
  end

  should 'create all' do
    @instance_creator.expects(:create_instance_created_email!).once
    @instance_creator.create_all!
  end

  context 'methods' do

    setup do
      @instance = FactoryGirl.create(:domain, name: 'newinstance.com', target: FactoryGirl.create(:instance, name: 'Shiny Instance')).target
      PlatformContext.current = PlatformContext.new(@instance)
      @user = FactoryGirl.create(:user)
      @user.instance_admins.create
      @password = 'secret_password'
    end

    should 'create_instance_created_email' do
      @instance_creator.create_instance_created_email!
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::InstanceWorkflow::Created, @instance.id, @user.id, @password)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_contains "Your marketplace, Shiny Instance, has been created", mail.html_part.body
      assert_contains "Password: secret_password", mail.html_part.body
      assert_contains 'href="https://newinstance.com/', mail.html_part.body
      assert_equal [@user.email], mail.to
      assert_not_contains 'href="https://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
      assert_equal "Instance created", mail.subject
    end
  end

end
