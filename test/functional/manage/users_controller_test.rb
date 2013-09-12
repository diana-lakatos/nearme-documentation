require 'test_helper'

class Manage::UsersControllerTest < ActionController::TestCase

  setup do
    @creator = FactoryGirl.create(:creator)
    sign_in @creator
    @company = FactoryGirl.create(:company, :creator => @creator)
    @company.users << @creator
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  context "#create" do

    setup do
      @user = FactoryGirl.create(:user)
    end

    should "create company user" do
      assert_difference('@company.users.count') do
        post :create, { :user => { :email => @user.email } }
      end
      assert_redirected_to manage_users_path
    end

    context "with user that not exists" do

      should "not create company user" do
        assert_no_difference('@company.users.count') do
          post :create, { :user => { :email => "not_existed_user@example.com" } }
        end
      end

    end
  end


  context "with company user" do

    setup do
      @user = FactoryGirl.create(:user)
    end 

    context "user already assigned to company" do

      setup do
        @company.users << @user
      end 

      should "not create company user" do
        assert_no_difference('@company.users.count') do
          post :create, { :user => { :email => @user.email } }
        end
      end

      should "destroy company user" do
        assert_difference('@company.users.count', -1) do
          delete :destroy, :id => @user.id
        end

        assert_redirected_to manage_users_path
      end
    end
  end

end
