require 'test_helper'

class DashboardControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @listing = FactoryGirl.create(:listing, :quantity => 1000)
    @listing.location.company.tap { |c| c.creator = @user }.save!
  end

  context '#payments' do

    context '#assigned variables' do

      context 'ownership' do
        setup do
          @owner_charge = create_charge(:currency => 'USD', :amount => 100)
          @not_owner_charge = FactoryGirl.create(:charge)
        end

        should '@last_week_charges ignores charges that do not belong to signed in user' do
          get :payments
          assert_equal [@owner_charge], assigns(:last_week_charges)
        end

        should '@charges ignores charges that do not belong to signed in user' do
          get :payments
          assert_equal [@owner_charge], assigns(:charges)
        end

      end

      context 'date' do 

        setup do
          @charge_created_6_days_ago = create_charge(:currency => 'USD', :amount => 100, :created_at => Time.now - 6.day)
          @charge_created_7_days_ago = create_charge(:currency => 'USD', :amount => 100, :created_at => Time.now - 7.day)
        end

        should '@last_week_charges includes only charges not older than 6 days' do
          get :payments
          assert_equal [@charge_created_6_days_ago], assigns(:last_week_charges)
        end

        should '@charges includes all charges that belong to a user' do
          get :payments
          assert_equal [@charge_created_6_days_ago, @charge_created_7_days_ago], assigns(:charges)
        end

      end

    end

  end

  private

  def create_charge(options = {})
    options.reverse_merge!({:reference => FactoryGirl.create(:reservation, :listing => @listing)})
    FactoryGirl.create(:charge, options)
  end

end

