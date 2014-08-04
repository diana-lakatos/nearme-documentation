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
        @other_company = FactoryGirl.create(:company, creator: @user)
        @other_location = FactoryGirl.create(:location, company: @other_company)
        FactoryGirl.create(:user_ban, user: @user)
        assert @other_company.reload.deleted?
        assert @other_location.reload.deleted?
        PlatformContext.current = PlatformContext.new
        refute @company.reload.deleted?
        refute @location.reload.deleted?
        refute @listing.reload.deleted?
      end

    end

    context 'user is not the only owner but creator' do

      setup do
        @other_user = FactoryGirl.create(:user)
        CompanyUser.create(user: @other_user, company: @company)
        @company.reload
      end

      context 'delete creator' do

        should 'assign other user to administer this company' do
          FactoryGirl.create(:user_ban, user: @user)
          refute @company.reload.deleted?
          refute @location.reload.deleted?
          refute @listing.reload.deleted?
          assert_equal @other_user.id, @company.creator_id
          assert_equal @other_user.id, @location.creator_id
          assert_equal @other_user.id, @listing.creator_id
        end

      end

      context 'delete other_user' do

        should 'change nothing' do
          FactoryGirl.create(:user_ban, user: @other_user)
          refute @company.reload.deleted?
          refute @location.reload.deleted?
          refute @listing.reload.deleted?
          assert_equal @user.id, @company.creator_id
          assert_equal @user.id, @location.creator_id
          assert_equal @user.id, @listing.creator_id
        end

      end
    end

  end
end

