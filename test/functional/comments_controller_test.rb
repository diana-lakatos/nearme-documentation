# frozen_string_literal: true
require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment_creator = FactoryGirl.create(:user)
    @transactable = FactoryGirl.create(:transactable)
  end

  context 'with authorized user' do
    setup do
      sign_in @comment_creator
    end

    should 'create comment' do
      assert_difference 'Comment.count', 1 do
        post :create, transactable_id: @transactable, comment: { body: 'Test body' }, format: :js
      end
      assert_response :success
    end
  end

  context 'without authorized user' do
    should 'list comment' do
      @comment = FactoryGirl.create :comment, creator: @comment_creator, commentable: @transactable
      xhr :get, :index, transactable_id: @transactable, format: :js
      assert_equal [@comment], assigns(:comments)
      assert_response :success
    end

    should 'be not created' do
      assert_difference 'Comment.count', 0 do
        post :create, transactable_id: @transactable, comment: { body: 'Test body' }, format: :js
      end
      assert_response :unauthorized
    end
  end
end
