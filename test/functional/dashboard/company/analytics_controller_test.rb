# frozen_string_literal: true
# require 'test_helper'

# class Dashboard::Company::AnalyticsControllerTest < ActionController::TestCase
#   setup do
#     @user = FactoryGirl.create(:user)
#     sign_in @user
#   end

#   context '#analytics' do
#     context '#revenue' do
#       setup do
#         @listing = FactoryGirl.create(:transactable, quantity: 1000)
#         @listing.location.company.update_attribute(:creator_id, @user.id)
#         @listing.location.company.add_creator_to_company_users
#       end

#       context '#assigned variables' do
#         context 'ownership' do
#           setup do
#             @owner_charge = create_payment(amount: 100)
#             @not_owner_charge = FactoryGirl.create(:charge)
#           end

#           should '@last_week_payments ignores charges that do not belong to signed in user' do
#             get :show
#             assert_equal [@owner_charge], assigns(:last_week_payments)
#           end

#           should '@payments ignores charges that do not belong to signed in user' do
#             get :show
#             assert_equal [@owner_charge], assigns(:payments)
#           end

#           should '@all_time_totals ' do
#             get :show
#             assert_equal 1, assigns(:all_time_totals).length
#           end
#         end

#         context 'date' do
#           setup do
#             @charge_created_6_days_ago = create_payment(amount: 100, created_at: Time.zone.now - 6.day)
#             @charge_created_7_days_ago = create_payment(amount: 100, created_at: Time.zone.now - 7.day)
#           end

#           should '@last_week_payments includes only charges not older than 6 days' do
#             get :show
#             assert_equal [@charge_created_6_days_ago], assigns(:last_week_payments)
#           end

#           should '@payments includes all charges that belong to a user' do
#             get :show
#             assert_equal [@charge_created_6_days_ago, @charge_created_7_days_ago], assigns(:payments)
#           end
#         end
#       end
#     end

#     context '#reservations' do
#       setup do
#         @listing = FactoryGirl.create(:transactable, quantity: 1000)
#         @listing.location.company.update_attribute(:creator_id, @user.id)
#         @listing.location.company.add_creator_to_company_users
#       end

#       context 'assigned variables' do
#         setup do
#           @reservation = FactoryGirl.create(:reservation, currency: 'USD', transactable: @listing)
#         end

#         should '@last_week_reservations includes user company reservations' do
#           get :show, analytics_mode: 'orders'
#           assert_equal [@reservation], assigns(:reservations)
#         end
#       end

#       context 'date' do
#         setup do
#           @reservation_created_6_days_ago = FactoryGirl.create(:reservation, currency: 'USD', transactable: @listing, created_at: Time.zone.now - 6.day)
#         end

#         should '@last_week_reservations includes only reservations not older than 6 days' do
#           get :show, analytics_mode: 'orders'
#           assert_equal [@reservation_created_6_days_ago], assigns(:last_week_reservations)
#         end
#       end
#     end

#     context '#location_views' do
#       setup do
#         @listing = FactoryGirl.create(:transactable, quantity: 1000)
#         @listing.location.company.update_attribute(:creator_id, @user.id)
#         @listing.location.company.add_creator_to_company_users
#       end

#       context 'date' do
#         setup do
#           create_location_visit
#         end

#         should '@last_month_visits has one visit from today' do
#           get :show, analytics_mode: 'location_views'
#           assert_equal Date.current, Date.strptime(assigns(:last_month_visits).first.impression_date.to_s)
#           assert_equal 1, assigns(:visits).size
#         end
#       end
#     end
#   end

#   private

#   def create_payment(options = {})
#     options[:paid_at] ||= options[:created_at] || Time.zone.now
#     options[:company] ||= @listing.company
#     if amount = options.delete(:amount)
#       options[:subtotal_amount] = amount
#     end
#     FactoryGirl.create(:confirmed_reservation, currency: 'USD', transactable: @listing, payment: FactoryGirl.build(:paid_payment, options)).payment
#   end

#   def create_location_visit
#     @listing.location.track_impression
#   end
# end
