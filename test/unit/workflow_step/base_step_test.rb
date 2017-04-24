# frozen_string_literal: true
require 'test_helper'

class WorkflowStep::BaseStepTest < ActiveSupport::TestCase
  class DummyStep < ::WorkflowStep::BaseStep
    def workflow_type
      'dummy_workflow_type'
    end

    def workflow_triggered_by
      nil
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
      WorkflowAlert::InvokerFactory.expects(:get_invoker).with(@alert1, metadata: {}).returns(@invoker_instance)
      WorkflowAlert::InvokerFactory.expects(:get_invoker).with(@alert2, metadata: {}).returns(@invoker_instance)
      @dummy_step.invoke!(as: nil)
    end

    should 'do not raise exception if relevant records are not in db' do
      assert_nothing_raised do
        DummyStep.new.invoke!(as: nil)
      end
    end
  end
end
