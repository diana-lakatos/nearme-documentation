# frozen_string_literal: true
require 'test_helper'
require 'graph/schema'

class Graph::SchemaTest < ActiveSupport::TestCase
  setup do
    @context = {}
    @variables = {}
  end

  context 'user query' do
    setup do
      @user = FactoryGirl.create(:user)
    end

    should 'get user' do
      query = %({ users { name } })

      assert_equal @user.name, result(query)['users'].first['name']
    end

    should 'get user custom attribute' do
      add_custom_attribute('hair_color', 'red', @user)

      query = %({ users { hair_color: custom_attribute(name: "hair_color") } })

      assert_equal @user.properties.hair_color, result(query)['users'].first['hair_color']
    end

    should 'get user custom photo' do
      query = %({ users { funny_pic: custom_attribute_photos(name: "funny_pic"){ url }}})

      assert_not_nil result(query)
    end

    should 'get user pending collaborations' do
      collaboration = FactoryGirl.create(
        :transactable_collaborator,
        user: @user, transactable:
        FactoryGirl.create(:transactable, user: @user)
      )
      User.where.not(id: @user.id).delete_all

      query = %({ users { collaborations(filters: [PENDING_RECEIVED_INVITATION]) { id } }})

      assert_equal({ 'users' => [{ 'collaborations' => [{ 'id' => collaboration.id }] }] }, result(query))
    end

    should 'get user pending group collaborations' do
      FactoryGirl.create(
        :group_member_pending,
        user: @user
      )
      query = %({
        user(id: #{@user.id}) {
          group_collaborations(filters: [PENDING_RECEIVED_INVITATION]) {
            id
            group {
              show_path cover_photo{ url(version: "thumb") }
              creator{ avatar_url_thumb }
            }
          }
        }})

      assert_not_nil result(query)
    end

    should 'user threads' do
      FactoryGirl.create(:user_message, author: @user)
      query = %({ user(id: #{@user.id}) { threads { participant { name } is_read }}})

      assert_equal(
        { 'user' => { 'threads' => [{ 'participant' => { 'name' => @user.name }, 'is_read' => false }] } },
        result(query)
      )
    end

    should 'user thread' do
      message = FactoryGirl.create(:user_message, author: @user, thread_owner: @user, thread_recipient: @user)
      query = %({ user(id: #{@user.id}) { thread(id: #{message.id}) { participant { name } is_read }}})

      assert_equal(
        { 'user' => { 'thread' => { 'participant' => { 'name' => @user.name }, 'is_read' => false } } },
        result(query)
      )
    end

    should 'user thread messages' do
      message = FactoryGirl.create(:user_message, author: @user, thread_owner: @user, thread_recipient: @user)
      FactoryGirl.create(:attachable_attachment, user: @user, attachable: message)
      query = %({ user(id: #{@user.id}) { thread(id: #{message.id}){ messages{attachments{url}}}}})
      assert_not_nil result(query)
    end

    should 'get activity feed' do
      query = %(
        {
          feed(include_user_feed: true, object_id: #{@user.id}, object_type: "User"){
            owner_id
            owner_type
            has_next_page
            events_next_page
            events{
              id
              name
            }
          }
        })

      assert_not_nil result(query)
    end
  end

  context 'transactable query' do
    should 'get transactable custom photo' do
      query = %({ transactables { funny_pic: custom_attribute_photos(name: "funny_pic"){ url }}})

      assert_not_nil result(query)
    end
  end

  def result(query)
    Graph.execute_query(
      query,
      context: @context,
      variables: @variables
    )
  end

  def add_custom_attribute(name, value, user)
    FactoryGirl.create(
      :custom_attribute,
      name: name, target: InstanceProfileType.default.first, attribute_type: 'string'
    )
    user.reload.properties.hair_color = value
    user.save!
  end
end
