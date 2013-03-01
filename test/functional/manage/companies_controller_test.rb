require 'test_helper'

class Manage::CompaniesControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end
  context "#index" do
    context "when the user does not have a company" do
      should "redirect to create company form if user does not have company" do
        get :index
        assert_redirected_to new_space_wizard_url
      end

      should "Notify the user they must first add a company" do
        get :index
        assert_equal "Please add your company first", flash[:success]
      end
    end

    context "When the user has a company" do
      should "redirect to the edit company page for the users first company" do
        company = FactoryGirl.create(:company, creator: @user)
        get :index
        assert_redirected_to edit_manage_company_url(company)
      end
    end
  end
end
