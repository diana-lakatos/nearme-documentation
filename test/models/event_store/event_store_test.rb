# frozen_string_literal: true
require 'test_helper'
require 'event_store'

class EventStoreTest < ActiveSupport::TestCase
  test 'publish event as class' do
    ::DummyEvent = Class.new(EventStore::Event)
    user = FactoryGirl.create(:user)

    event = EventStore.publish_event(
      DummyEvent.new(
        payload: { foo: :bar, user: user },
        triggered_by: user
      )
    )

    assert_equal event.payload[:foo], :bar
    assert_equal(event.payload[:user], class_name: 'User', id: user.id)
    assert_equal event.event_type, 'DummyEvent'
  end

  test 'publish event from workflow step' do
    user = FactoryGirl.create(:user)
    step = WorkflowStep::SignUpWorkflow::AccountCreated.new(user.id)

    event = step.publish_event

    assert_equal event.event_type, 'WorkflowStep::SignUpWorkflow::AccountCreated'
  end

  test 'publish event from workflow step with user decorator' do
    user = FactoryGirl.create(:user)
    step = WorkflowStep::SignUpWorkflow::AccountCreated.new(user.id)

    event = step.invoke!(user.decorate)

    assert_equal event.event_type, 'WorkflowStep::SignUpWorkflow::AccountCreated'
  end

  test 'publish event with user decorator' do
    ::DummyEvent = Class.new(EventStore::Event)
    user = FactoryGirl.create(:user)

    event = EventStore.publish_event(
      DummyEvent.new(
        payload: { foo: :bar, user: user },
        triggered_by: user.decorate
      )
    )

    assert_equal event.payload[:foo], :bar
  end
end
