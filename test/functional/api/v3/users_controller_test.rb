require 'test_helper'

class Api::V3::UsersControllerTest < ActionController::TestCase

  context '#create' do
    should "should create user with valid attributes" do
      assert_difference('User.count') do
        post :create, user: user_attributes, format: :json
      end
      assert_equal ApiSerializer.serialize_object(assigns(:user)), JSON.parse(response.body)
    end

    context 'force accepting ToS' do
      setup do
        PlatformContext.current.instance.update_attribute(:force_accepting_tos, true)
      end

      should 'not sign up without accepting terms if required' do
        assert_no_difference('User.count') do
          post :create, user: user_attributes, format: :json
          assert_equal ApiSerializer.serialize_errors(assigns(:user).errors), JSON.parse(response.body)
        end
      end

      should 'sign up after accepting ToS' do
        assert_difference('User.count') do
          post :create, user: user_attributes.merge({accept_terms_of_service: "1"}), format: :json
          assert_equal ApiSerializer.serialize_object(assigns(:user)), JSON.parse(response.body)
        end
      end
    end
  end

  private

  def user_attributes
    { name: 'Test User', email: 'user@example.com', password: 'secret' }
  end

end

