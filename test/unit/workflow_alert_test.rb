require 'test_helper'

class WorkflowAlertTest < ActiveSupport::TestCase

  context 'validation' do

    setup do
      @workflow_alert = FactoryGirl.build(:workflow_alert)
    end

    context 'from' do
      should 'be valid if is email' do
        @workflow_alert.from = 'email@example.com'
        assert @workflow_alert.valid?, @workflow_alert.errors.full_messages.join(', ')
      end

      should 'be invalid if not email' do
        @workflow_alert.from = 'Super Team'
        refute @workflow_alert.valid?, @workflow_alert.errors.full_messages.join(', ')
      end
    end

    context 'bcc' do
      should 'be valid if all entries are emails' do
        @workflow_alert.bcc = 'email@example.com, Super Team <super_team@example.com>'
        assert @workflow_alert.valid?, @workflow_alert.errors.full_messages.join(', ')
      end

      should 'be invalid if at least one entry is not email' do
        @workflow_alert.bcc = 'email@example.com, Super Team'
        refute @workflow_alert.valid?
      end
    end

    context 'cc' do
      should 'be valid if all entries are emails' do
        @workflow_alert.cc = 'email@example.com, Super Team <super_team@example.com>'
        assert @workflow_alert.valid?, @workflow_alert.errors.full_messages.join(', ')
      end

      should 'be invalid if at least one entry is not email' do
        @workflow_alert.cc = 'email@example.com, Super Team'
        refute @workflow_alert.valid?
      end
    end
  end
end

