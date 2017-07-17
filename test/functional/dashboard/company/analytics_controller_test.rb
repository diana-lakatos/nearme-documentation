# frozen_string_literal: true
# frozen_string_literal: true

require 'test_helper'

class Dashboard::Company::AnalyticsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  context '#analytics' do
    context '#revenue' do
      setup do
        @listing = FactoryGirl.create(:transactable, quantity: 1000)
        @listing.location.company.update_attribute(:creator_id, @user.id)
        @listing.location.company.add_creator_to_company_users
      end

      context '#assigned variables' do
        context 'ownership' do
          setup do
            @owner_charge = create_payment(amount: 100)
            @not_owner_charge = FactoryGirl.create(:charge)
          end

          should '@last_week_payments ignores charges that do not belong to signed in user' do
            get :show
            assert_equal [@owner_charge], assigns(:analytics).list
          end

          should '@payments ignores charges that do not belong to signed in user' do
            get :show
            assert_equal [@owner_charge], assigns(:analytics).list
          end

          should '@all_time_totals ' do
            get :show
            assert_equal 1, assigns(:analytics).list.count
          end
        end

        context 'date' do
          should '@last_week_payments includes only charges not older than 6 days' do
            travel_to 'next monday 5pm' do
              @charge_created_6_days_ago = create_payment(total_amount: 100, created_at: Time.now - 6.days)
              @charge_created_7_days_ago = create_payment(total_amount: 100, created_at: Time.now - 7.days)
              get :show
              assert_equal [[100, 0, 0, 0, 0, 0, 0]], assigns(:analytics).values
            end
          end

          should '@payments includes all charges that belong to a user' do
            travel_to 'next monday 5pm' do
              @charge_created_6_days_ago = create_payment(total_amount: 100, created_at: Time.now - 6.days)
              @charge_created_7_days_ago = create_payment(total_amount: 100, created_at: Time.now - 7.days)
              get :show
              assert_equal [@charge_created_6_days_ago, @charge_created_7_days_ago], assigns(:analytics).list
            end
          end
        end
      end
    end

    context '#reservations' do
      setup do
        @listing = FactoryGirl.create(:transactable, quantity: 1000)
        @listing.location.company.update_attribute(:creator_id, @user.id)
        @listing.location.company.add_creator_to_company_users
      end

      context 'assigned variables' do
        setup do
          @reservation = FactoryGirl.create(:reservation, currency: 'USD', transactable: @listing, state: 'confirmed')
        end

        should '@last_week_reservations includes user company reservations' do
          get :show, analytics_mode: 'orders'
          assert_equal [@reservation], assigns(:analytics).list
        end
      end

      context 'date' do
        setup do
          @reservation_created_6_days_ago = FactoryGirl.create(:reservation, currency: 'USD', transactable: @listing, created_at: Time.zone.now - 6.days, state: 'confirmed')
        end

        should '@last_week_reservations includes only reservations not older than 6 days' do
          get :show, analytics_mode: 'orders'
          assert_equal [@reservation_created_6_days_ago], assigns(:analytics).list
        end
      end
    end
  end

  private

  def create_payment(options = {})
    options[:paid_at] ||= options[:created_at] || Time.zone.now
    options[:company] ||= @listing.company
    if amount = options.delete(:amount)
      options[:subtotal_amount] = amount
    end
    FactoryGirl.create(:confirmed_reservation, currency: 'USD', transactable: @listing, payment: FactoryGirl.build(:paid_payment, options)).payment
  end
end
