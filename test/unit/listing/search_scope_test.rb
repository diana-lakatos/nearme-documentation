require 'test_helper'

class Listing::SearchScopeTest < ActiveSupport::TestCase

  setup do
    @platform_context = PlatformContext.new
    @company = FactoryGirl.create(:white_label_company)
    @location = FactoryGirl.create(:location, company: @company)
    @another_location = FactoryGirl.create(:location)
  end


  should 'scope to locations of this company' do
    @platform_context.stubs(:white_label_company).returns(@company)
    assert_equal [@location], Listing::SearchScope.scope(@platform_context)
  end

  context 'instance' do

    setup do
      @other_instance = FactoryGirl.create(:instance, :name => 'other name')
      @other_company = FactoryGirl.create(:company, :instance => @other_instance)
      @other_location = FactoryGirl.create(:location, :company => @other_company)
    end

    should 'find all locations not matter what instance for default_instance' do
      assert_equal Location.all.sort, Listing::SearchScope.scope(@platform_context).sort
    end

    should 'find locations scoped to instance if it is not default' do 
      @platform_context.stubs(:instance).returns(@other_instance)
      assert_equal @other_instance.locations, Listing::SearchScope.scope(@platform_context)
    end
  end

  should 'include only public locations' do
    @private_location = FactoryGirl.create(:location, company: FactoryGirl.create(:company, :listings_public => false))
    assert_equal (Location.all - [@private_location]).sort, Listing::SearchScope.scope(@platform_context).sort
  end

end
