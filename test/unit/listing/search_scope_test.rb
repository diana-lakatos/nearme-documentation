require 'test_helper'

class Listing::SearchScopeTest < ActiveSupport::TestCase

  context 'with white label company' do
    setup do
      @company = FactoryGirl.create(:white_label_company)
    end

    context 'with locations existing' do

      setup do
        @location = FactoryGirl.create(:location, company: @company)
        @another_location = FactoryGirl.create(:location)
      end

      should 'scope to locations of this company' do
        @search_scope = Listing::SearchScope.new(white_label_company: @company)
        assert_equal [@location], @search_scope.locations
      end

      should 'scope to all locations' do
        @search_scope = Listing::SearchScope.new
        assert_equal Location.all, @search_scope.locations
      end

    end

    context 'with user associated to company' do

      setup do
        @user = FactoryGirl.create(:user, companies: [@company])
        @another_user = FactoryGirl.create(:user)
      end

      should 'allow that user_can_add_listing? when there is no white label white_label_company' do
        @search_scope = Listing::SearchScope.new
        assert @search_scope.user_can_add_listing?
      end

      should 'not allow that user_can_add_listing? when user doesnt belong to white label company' do
        @search_scope = Listing::SearchScope.new(white_label_company: @company, user: @another_user)
        refute @search_scope.user_can_add_listing?
      end

      should 'allow that user_can_add_listing? when user belongs to white label company' do
        @search_scope = Listing::SearchScope.new(white_label_company: @company, user: @user)
        assert @search_scope.user_can_add_listing?
      end
    end

  end

end
