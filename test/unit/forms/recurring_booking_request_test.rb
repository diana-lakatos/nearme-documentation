# require 'test_helper'


# ## NOTE
# ## RecurringBooking is temporary out of service
# ## Some refactor will happen in this area we are soon.


# class RecurringBookingRequestTest < ActiveSupport::TestCase

#   setup do
#     @listing = FactoryGirl.create(:subscription_transactable)
#     @instance = @listing.instance
#     @user = FactoryGirl.create(:user, name: "Firstname Lastname")
#     @payment_method = FactoryGirl.create(:credit_card_payment_method)
#     @attributes = {
#       schedule_params: "{\"validations\":{\"day\":[1, 5]}, \"rule_type\":\"IceCube::WeeklyRule\", \"interval\":1, \"week_start\":0}",
#       starts_at: @first_monday,
#       ends_at: @last_thursday,
#       quantity: 1,
#       transactable_pricing_id: @listing.action_type.pricings.first.id,
#       payment_subscription_attributes: {
#         payment_method: @payment_method,
#         credit_card_attributes: {
#           first_name: "Charles",
#           last_name: "Darwin",
#           number: 4242424242424242,
#           month: '05',
#           year: '2020',
#           verification_value: "411"
#         }
#       }
#     }
#     stub_billing_gateway(@instance)
#     stub_active_merchant_interaction
#     @recurring_booking_request = RecurringBookingRequest.new(@listing, @user, PlatformContext.new(@instance), @attributes)
#   end

#   context "#initialize" do

#     should "set user" do
#       assert_equal @recurring_booking_request.user, @user
#     end

#     should "set listing" do
#       assert_equal @recurring_booking_request.listing, @listing
#     end

#     context 'determine payment method' do

#       should 'set credit card' do
#         Instance.any_instance.stubs(:payment_gateway).returns(FactoryGirl.build(:stripe_payment_gateway))
#         assert_equal @payment_method, RecurringBookingRequest.new(@listing, @user, PlatformContext.new(@instance), @attributes).payment_subscription.payment_method
#       end

#       should 'set manual' do
#         Instance.any_instance.stubs(:payment_gateway).returns(nil)
#         assert_equal @payment_method, RecurringBookingRequest.new(@listing, @user, PlatformContext.new(@instance), @attributes).payment_subscription.payment_method
#       end
#     end
#   end

#   context "validations" do

#     should "raise error when total_price_check is incorrect" do
#       @recurring_booking_request.total_amount_check = @recurring_booking_request.recurring_booking.total_amount.cents
#       assert @recurring_booking_request.valid?
#       @recurring_booking_request.total_amount_check = 1 + @recurring_booking_request.recurring_booking.total_amount.cents
#       refute @recurring_booking_request.valid?
#       error = I18n.t("activemodel.errors.models.reservation_request.attributes.base.total_amount_changed")
#       assert_equal error, @recurring_booking_request.errors.full_messages.to_sentence
#     end


#     context "invalid arguments" do
#       context "no listing" do
#         should "be invalid" do
#           recurring_booking_request = RecurringBookingRequest.new(nil, @user, PlatformContext.new(@instance), @attributes)
#           assert !recurring_booking_request.valid?
#         end
#       end

#       context "no user" do
#         should "be invalid" do
#           recurring_booking_request = RecurringBookingRequest.new(@listing, nil, PlatformContext.new(@instance), @attributes)
#           assert !recurring_booking_request.valid?
#         end
#       end

#       context "no recurring_booking" do

#         setup do
#           @recurring_booking_request.stubs(:recurring_booking).returns(nil)
#         end

#         should "be invalid" do
#           assert !@recurring_booking_request.valid?
#         end

#       end
#     end
#   end

#   context "#process" do

#     context "invalid" do

#       setup do
#         @recurring_booking_request.stubs(:valid?).returns(false)
#       end

#       should "return false" do
#         assert !@recurring_booking_request.process
#       end
#     end
#   end

#   context "#display_phone_and_country_block?" do
#     context "country_name is blank" do
#       setup do
#         @user.stubs(:country_name).returns(nil)
#       end
#       should "return true" do
#         assert @recurring_booking_request.display_phone_and_country_block?
#       end
#     end

#     context "phone is blank" do
#       setup do
#         @user.stubs(:phone).returns(nil)
#       end
#       should "return true" do
#         assert @recurring_booking_request.display_phone_and_country_block?
#       end
#     end

#     context "country_name and phone are set" do
#       should "return false" do
#         assert !@recurring_booking_request.display_phone_and_country_block?
#       end
#     end
#   end

# end
