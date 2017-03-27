# frozen_string_literal: true
require 'test_helper'

class EventStoreTest < ActiveSupport::TestCase
  test 'serialize simple objects' do
    time = Time.zone.now
    data = {
      foo: :bar,
      number: 1,
      time: time
    }

    serializer = EventStore::EventDataSerializer.new(data)

    assert_equal(data, serializer.to_h)
  end

  test 'serialize AR objects' do
    comment = FactoryGirl.create(:comment)
    data = {
      comment: comment,
      foo: :bar
    }

    serializer = EventStore::EventDataSerializer.new(data)

    assert_equal(
      {
        comment: { class_name: 'Comment', id: comment.id },
        foo: :bar
      },
      serializer.to_h
    )
  end

  test 'serialize array with AR objects' do
    comments = (1..2).map { FactoryGirl.create(:comment) }
    data = { comments: comments }

    serializer = EventStore::EventDataSerializer.new(data)

    assert_equal(
      {
        comments: [
          { class_name: 'Comment', id: comments[0].id },
          { class_name: 'Comment', id: comments[1].id }
        ]
      },
      serializer.to_h
    )
  end

  test 'serialize hash with AR objects' do
    comment = FactoryGirl.create(:comment)
    data = { foo: { comment: comment } }

    serializer = EventStore::EventDataSerializer.new(data)

    assert_equal(
      {
        foo: { comment: { class_name: 'Comment', id: comment.id } }
      },
      serializer.to_h
    )
  end
end
