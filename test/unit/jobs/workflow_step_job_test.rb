require 'test_helper'

class MailerJobTest < ActiveSupport::TestCase
  setup do
    @workflow_step_instance = stub
  end

  context '#perform' do
    should 'trigger invoke' do
      @workflow_step_class = mock(new: @workflow_step_instance)
      @workflow_step_instance.expects(:invoke!)
      WorkflowStepJob.perform(@workflow_step_class)
    end

    should 'invoke mailing method with given arguments' do
      @workflow_step_class = stub
      @workflow_step_class.expects(:new).with(1, 2, 3).returns(stub("invoke!": true))
      WorkflowStepJob.perform(@workflow_step_class, 1, 2, 3)
    end
  end
end
