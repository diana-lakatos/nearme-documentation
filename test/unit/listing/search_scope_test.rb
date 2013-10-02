require 'test_helper'

class Listing::SearchScopeTest < ActiveSupport::TestCase

  setup do
    @instance = Instance.default_instance
    @company = FactoryGirl.create(:white_label_company)
  end

    setup do
      @location = FactoryGirl.create(:location, company: @company)
      @another_location = FactoryGirl.create(:location)
    end


    should 'scope to locations of this company' do
      assert_equal [@location], Listing::SearchScope.scope(@instance, white_label_company: @company)
    end

    should 'scope to all instance locations' do
      assert_equal @instance.locations, Listing::SearchScope.scope(@instance)
    end

    should 'include only public locations' do
      @private_location = FactoryGirl.create(:location, company: FactoryGirl.create(:company, :listings_public => false))
      assert_equal (@instance.locations.all - [@private_location]), Listing::SearchScope.scope(@instance)
    end

end
