require 'test_helper'

class ReservationRequestTest < ActiveSupport::TestCase

  setup do
    listing = FactoryGirl.build_stubbed(:listing, :name => "blah")
    @user = FactoryGirl.create(:user)
    @date = Date.today + 1.day
    attributes = {
      :dates => [@date.to_s(:db)]
    }
    @reservation_request = ReservationRequest.new(listing, @user, attributes)
  end

  context "#form_title" do
    should "return proper value" do
      assert_equal @reservation_request.form_title, "1 blah"
    end
  end

  context "#reservation_periods" do
    should "return proper values" do
      assert_equal @reservation_request.reservation_periods.map { |rp| rp.date }, [@date]
    end
  end

  context "#display_phone_and_country_block?" do
    context "country_name is blank" do
      setup do
        @user.stubs(:country_name).returns(nil)
      end
      should "return true" do
        assert @reservation_request.display_phone_and_country_block?
      end
    end

    context "phone is blank" do
      setup do
        @user.stubs(:phone).returns(nil)
      end
      should "return true" do
        assert @reservation_request.display_phone_and_country_block?
      end
    end

    context "country_name and phone are set" do
      should "return false" do
        assert !@reservation_request.display_phone_and_country_block?
      end
    end

  end

end