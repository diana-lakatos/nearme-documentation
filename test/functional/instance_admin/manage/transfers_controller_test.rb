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
      @payment_transfer = FactoryGirl.create(:payment_transfer, :company => @company)

      get :index
      assert_select 'td', @company.name
      assert_equal [@payment_transfer], assigns(:transfers)
    end

    should 'show a listing of payment transfers associated with current instance' do
      @instance = FactoryGirl.create(:instance)
      @company = FactoryGirl.create(:company)
      @company.update_attribute(:instance_id, @instance.id)
      @payment_transfer = FactoryGirl.create(:payment_transfer, company: @company)
      @payment_transfer.update_attribute(:instance_id, @instance.id)

      @other_company = FactoryGirl.create(:company)
      @other_payment_transfer = FactoryGirl.create(:payment_transfer, company: @other_company)
      PlatformContext.current = PlatformContext.new(@instance)
      get :index
      assert_select 'td', @company.name
      assert_equal [@payment_transfer], assigns(:transfers)
    end
  end

end

