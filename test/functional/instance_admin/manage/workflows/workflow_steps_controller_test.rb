require 'test_helper'

class InstanceAdmin::Manage::Workflows::WorkflowStepsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @transactable_type = FactoryGirl.create(:transactable_type)
    FactoryGirl.create(:instance_admin, user: @user)
    sign_in @user
  end

  should 'not raise exception' do
    @workflow_step = FactoryGirl.create(:workflow_step)
    assert_nothing_raised do
      get :edit, workflow_id: @workflow_step.workflow_id, id: @workflow_step.id
    end
  end
end
