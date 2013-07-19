require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  context 'GET bookings' do
    setup do
      @company = FactoryGirl.create(:company_in_auckland, :creator_id => @user.id)
      @location = FactoryGirl.create(:location_in_auckland)
      @company.locations << @location
    end

    should 'redirect if no bookings' do
      get :bookings
      assert_redirected_to search_path
      assert_equal "You haven't made any bookings yet!", flash[:warning]
    end

    should 'render view if any bookings' do
      FactoryGirl.create(:reservation, owner: @user)
      get :bookings
      assert_response :success
    end
  end

  context '#payments' do
    setup do
      @listing = FactoryGirl.create(:listing, :quantity => 1000)
      @listing.location.company.tap { |c| c.creator = @user }.save!
    end

    context '#assigned variables' do

      context 'ownership' do
        setup do
          @owner_charge = create_charge(:amount => 100)
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
          @charge_created_6_days_ago = create_charge(:amount => 100, :created_at => Time.zone.now - 6.day)
          @charge_created_7_days_ago = create_charge(:amount => 100, :created_at => Time.zone.now - 7.day)
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
    options.reverse_merge!({:reservation => FactoryGirl.create(:reservation, :currency => 'USD', :listing => @listing)})
    if amount = options.delete(:amount)
      options[:subtotal_amount] = amount
    end

    options[:paid_at] ||= options[:created_at] || Time.zone.now

    FactoryGirl.create(:reservation_charge, options)
  end

end

