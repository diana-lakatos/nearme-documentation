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
      assert_equal "You've added #{@user.name} to #{@company.name}", flash[:success]
    end

    context "with user that not exists" do
      should "not create company user" do
        assert_no_difference('@company.users.count') do
          post :create, { :user => { :email => "not_existed_user@example.com" } }
        end
        assert_equal "A user does not exist with the specified email address.", flash[:warning]
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
        assert_equal "This user couldn't be invited as they are already associated with a company.", flash[:warning]
      end

      should "destroy company user" do
        assert_difference('@company.users.count', -1) do
          delete :destroy, :id => @user.id
        end
        assert_equal "You've removed #{@user.name} from #{@company.name}", flash[:deleted]
        assert_redirected_to manage_users_path
      end

      should "creator cannot destroy himself" do
        assert_no_difference('@company.users.count') do
          delete :destroy, :id => @creator.id
        end
        assert_equal "You can't delete self.", flash[:warning]
        assert_redirected_to manage_users_path
      end 

      should "can't destroy invalid user" do
        assert_no_difference('@company.users.count') do
          delete :destroy, :id => "invalid_user"
        end
        assert_equal "You can't delete user which is not in your company.", flash[:warning]
        assert_redirected_to manage_users_path
      end 
    end
  end
end
