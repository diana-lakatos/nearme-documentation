require 'test_helper'

class UserBanTest < ActiveSupport::TestCase

  context 'create' do

    setup do
      @user = FactoryGirl.create(:user)
      @company = FactoryGirl.create(:company, creator: @user)
      @location = FactoryGirl.create(:location, company: @company)
      @listing = FactoryGirl.create(:transactable, location: @location)
    end

    context 'user is the only owner of a company' do

      should 'delete everything related to user and certain instance' do
        FactoryGirl.create(:user_ban, user: @user)
        assert @company.reload.deleted?
        assert @location.reload.deleted?
        assert @listing.reload.deleted?
      end

      should 'ignore things in other instances' do
        PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
        @user = FactoryGirl.create(:user)
        @other_company = FactoryGirl.create(:company, creator: @user)
        @other_location = FactoryGirl.create(:location, company: @other_company)
        FactoryGirl.create(:user_ban, user: @user)
        assert @other_company.reload.deleted?
        assert @other_location.reload.deleted?
        PlatformContext.current = PlatformContext.new(FactoryGirl.create(:instance))
        refute @company.reload.deleted?
        refute @location.reload.deleted?
        refute @listing.reload.deleted?
      end

    end

  end
end

