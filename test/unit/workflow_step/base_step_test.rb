require 'test_helper'

class WorkflowStep::BaseStepTest < ActiveSupport::TestCase
  class DummyStep < ::WorkflowStep::BaseStep
    def workflow_type
      'dummy_workflow_type'
    end
  end

  setup do
  end

  context 'invoke!' do
    should 'process all alerts associated with this step' do
      @alert1 = stub(alert_type: 'email')
      @alert2 = stub(alert_type: 'email')
      @dummy_step = DummyStep.new
      @dummy_step.expects(:alerts).returns(stub(enabled: [@alert1, @alert2]))
      @invoker_instance = stub
      @invoker_instance.expects(:invoke!).with(@dummy_step).twice
      WorkflowAlert::InvokerFactory.expects(:get_invoker).with(@alert1).returns(@invoker_instance)
      WorkflowAlert::InvokerFactory.expects(:get_invoker).with(@alert2).returns(@invoker_instance)
      @dummy_step.invoke!
    end

    should 'do not raise exception if relevant records are not in db' do
      assert_nothing_raised do
        DummyStep.new.invoke!
      end
    end
  end
end
