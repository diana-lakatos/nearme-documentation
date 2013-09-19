require 'test_helper'

class DashboardControllerTest < ActionController::TestCase

  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  context '#payments' do

    setup do
      @listing = FactoryGirl.create(:listing, :quantity => 1000)
      @listing.location.company.tap { |c| c.creator = @user }.save!
      @listing.location.company.add_creator_to_company_users
    end

    context '#assigned variables' do

      context 'ownership' do
        setup do
          @owner_charge = create_reservation_charge(:amount => 100)
          @not_owner_charge = FactoryGirl.create(:reservation_charge)
        end

        should '@last_week_reservation_charges ignores charges that do not belong to signed in user' do
          get :payments
          assert_equal [@owner_charge], assigns(:last_week_reservation_charges)
        end

        should '@reservation_charges ignores charges that do not belong to signed in user' do
          get :payments
          assert_equal [@owner_charge], assigns(:reservation_charges)
        end

      end

      context 'date' do 

        setup do
          @charge_created_6_days_ago = create_reservation_charge(amount: 100, created_at: Time.zone.now - 6.days)
          @charge_created_7_days_ago = create_reservation_charge(amount: 100, created_at: Time.zone.now - 7.days)
        end

        should '@last_week_charges includes only charges not older than 6 days' do
          get :payments
          assert_equal [@charge_created_6_days_ago], assigns(:last_week_reservation_charges)
        end

        should '@charges includes all charges that belong to a user' do
          get :payments
          assert_equal [@charge_created_6_days_ago, @charge_created_7_days_ago], assigns(:reservation_charges)
        end

      end

    end

  end

  private

  def create_reservation_charge(options = {})
    options.reverse_merge!({:reservation => FactoryGirl.create(:reservation, :currency => 'USD', :listing => @listing)})
    if amount = options.delete(:amount)
      options[:subtotal_amount] = amount
    end

    options[:paid_at] ||= options[:created_at] || Time.zone.now

    FactoryGirl.create(:reservation_charge, options)
  end

end

