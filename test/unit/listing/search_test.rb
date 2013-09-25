require 'test_helper'

class Listing::SearchTest < ActiveSupport::TestCase
  context ".find_by_search_params" do
    context 'with no matched location' do
      setup do
        @params = mock(:midpoint => nil, :radius => nil)
      end

      should "return empty array" do
        assert_equal [], Listing.find_by_search_params(@params, Listing::SearchScope.new(FactoryGirl.create(:instance)))
      end
    end

    context 'should search by a midpoint' do
      setup do
        @midpoint = [1,2]
        @radius = 5.0
        @params = mock(:midpoint => @midpoint, :radius => @radius, :available_dates => [])
      end

      should "find listings by all companies by searching for locations" do
        instance = FactoryGirl.create(:instance)
        company1 = FactoryGirl.create(:company, instance: instance)
        company2 = FactoryGirl.create(:company, instance: instance)
        location1 = FactoryGirl.create(:location, company: company1)
        location2 = FactoryGirl.create(:location, company: company2)
        listing1 = FactoryGirl.create(:listing, location: location1)
        listing2 = FactoryGirl.create(:listing, location: location2)
        includes = stub(:includes => [listing1.location])
        Location.expects(:near).with(@midpoint, @radius, :order => :distance).returns(includes)

        results = Listing.find_by_search_params(@params, Listing::SearchScope.new(instance))
        assert_equal [listing1], results
      end

    end
  end
end
