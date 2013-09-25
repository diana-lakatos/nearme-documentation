require 'test_helper'

class Listing::SearchScopeTest < ActiveSupport::TestCase

  context 'with white label company' do
    setup do
      @company = FactoryGirl.create(:white_label_company)
      @instance = @company.instance
    end

    context 'with locations existing' do

      setup do
        @location = FactoryGirl.create(:location, company: @company)
        @another_company_location = FactoryGirl.create(:location)
      end

      should 'scope to locations of this company' do
        @search_scope = Listing::SearchScope.new(@instance, white_label_company: @company)
        assert_equal [@location], @search_scope.locations
      end

      should 'scope to all locations' do
        @search_scope = Listing::SearchScope.new(@instance)
        assert_equal @instance.locations.all, @search_scope.locations
      end

      context 'with listings private' do
        setup do
          @company.update_column(:listings_public, false)
        end

        should 'see all locations of white label company' do
          @another_location = FactoryGirl.create(:location, company: @company)
          @search_scope = Listing::SearchScope.new(@instance, white_label_company: @company)

          assert @search_scope.locations.include?(@location)
          assert @search_scope.locations.include?(@another_location)
          refute @search_scope.locations.include?(@another_company_location)
          assert_equal 2, @search_scope.locations.size
        end

        should 'scope to public locations only' do
          @search_scope = Listing::SearchScope.new(@instance)
          refute @search_scope.locations.include?(@location)
          refute @search_scope.locations.include?(@another_location)
          assert @search_scope.locations.include?(@another_company_location)
        end

      end

    end

  end

end
