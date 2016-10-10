require 'test_helper'

class InstanceAdmin::Manage::TransfersControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
    sign_in @user
  end

  context 'index' do
    should 'show a listing of payment transfers' do
      @company = FactoryGirl.create(:company)
      @payment_transfer = FactoryGirl.create(:payment_transfer, company: @company)

      get :index
      assert_select 'td', @company.name
      assert_equal [@payment_transfer].map(&:id), assigns(:payment_transfers).map(&:id)
    end

    should 'show a listing of payment transfers associated with current instance' do
      @instance = FactoryGirl.create(:instance)
      @other_company = FactoryGirl.create(:company)
      @other_payment_transfer = FactoryGirl.create(:payment_transfer, company: @other_company)
      PlatformContext.current = PlatformContext.new(@instance)
      @user = FactoryGirl.create(:user)
      sign_in @user
      @company = FactoryGirl.create(:company)
      @payment_transfer = FactoryGirl.create(:payment_transfer, company: @company)

      get :index
      assert_select 'td', @company.name
      assert_equal [@payment_transfer].map(&:id), assigns(:payment_transfers).map(&:id)
    end
  end
end
