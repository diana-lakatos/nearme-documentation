require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @project_creator = FactoryGirl.create :user
    @comment_creator = FactoryGirl.create :user
    @project = FactoryGirl.create :project, creator: @project_creator

    sign_in @comment_creator
  end


  test "should create comment" do
    assert_difference "Comment.count", 1 do
      post :create, project_id: @project, comment: {body: "Test body"}, format: :js
    end
    assert_response :success
  end

  test "should list comment" do
    @comment = FactoryGirl.create :comment, creator: @comment_creator, commentable: @project
    xhr :get, :index, project_id: @project, format: :js
    assert_equal [@comment], assigns(:comments)
    assert_response :success
  end
end
