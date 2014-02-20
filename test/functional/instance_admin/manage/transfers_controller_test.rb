require 'test_helper'

class InstanceAdmin::Manage::TransfersControllerTest < ActionController::TestCase

  setup do
    @instance = FactoryGirl.create(:instance)
    @user = FactoryGirl.create(:user, :instance => @instance)
    PlatformContext.any_instance.stubs(:instance).returns(@instance)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do

    should 'show a listing of payment transfers associated with current instance' do
      @company = FactoryGirl.create(:company, instance: @instance)
      @payment_transfer = FactoryGirl.create(:payment_transfer, company: @company)

      @other_instance = FactoryGirl.create(:instance)
      @other_company = FactoryGirl.create(:company, instance: @other_instance)
      @other_payment_transfer = FactoryGirl.create(:payment_transfer, company: @other_company)

      get :index
      assert_select 'td', @company.name
      assert_equal [@payment_transfer], assigns(:transfers)
    end
  end

end

