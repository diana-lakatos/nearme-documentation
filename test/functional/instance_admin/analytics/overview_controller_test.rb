require 'test_helper'

class InstanceAdmin::Analytics::OverviewControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    InstanceAdminAuthorizer.any_instance.stubs(:instance_admin?).returns(true)
    InstanceAdminAuthorizer.any_instance.stubs(:authorized?).returns(true)
  end

  context 'show' do

    should 'show listings from last 30 days' do
      @fresh_transactable = FactoryGirl.create(:transactable)
      @old_transactable = FactoryGirl.create(:transactable).update_column(:created_at, 31.days.ago)
      get :show
      assert_response :success
      assert_equal(
        [{"listings_count"=>1, "listing_date"=>Date.today, "transactable_type_id"=>TransactableType.first.id, "id"=> nil}].to_json,
        assigns(:last_month_listings).map(&:attributes).to_json
      )
    end
  end

end
