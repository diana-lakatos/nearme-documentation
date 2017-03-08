require 'test_helper'

class Listings::OrdersControllerTest < ActionController::TestCase
  setup do
    @transactable = FactoryGirl.create(:listing_in_san_francisco)

    @user = FactoryGirl.create(:user, name: 'Example LastName')
    sign_in @user

    @payment_gateway = stub_billing_gateway(@transactable.instance)
    @payment_method = @payment_gateway.payment_methods.first
    stub_active_merchant_interaction

    Instance.any_instance.stubs(:use_cart?).returns(false)
  end

  context 'cancellation policy' do
    should 'store cancellation policy details if cancellation policy set' do
      create_cancellation_policies(TransactableType::ActionType.last)
      post :create, order_params_for(@transactable)
      order = assigns(:order)
      assert_equal 3, order.cancellation_policies.count
      assert order.cancellable?
      order.update_column(:starts_at, Chronic.parse('Last Friday'))
      refute order.cancellable?
    end

    should 'not store cancellation policy details if disabled' do
      post :create, order_params_for(@transactable)
      order = assigns(:order)
      assert_equal 0, order.cancellation_policies.count
      assert order.cancellable?
    end
  end

  context 'versions' do
    should 'store new version after creating reservation' do
      assert_difference('PaperTrail::Version.where("item_type = ? AND event = ?", "Reservation", "create").count') do
        with_versioning do
          post :create, order_params_for(@transactable)
        end
      end
    end
  end

  context 'Book It Out' do
    setup do
      @transactable = FactoryGirl.create(:transactable, :fixed_price)
      @params = order_params_for(@transactable)
      next_available_occurrence = @transactable.next_available_occurrences.first[:id].to_i
      @params[:order].merge!(book_it_out: 'true', dates: next_available_occurrence, quantity: 10)
    end

    should 'create reservation with discount' do
      post :create, @params
      reservation = Reservation.last
      assert_redirected_to order_checkout_path(Reservation.last)
      assert_equal reservation.book_it_out_discount, @transactable.action_type.pricing.book_it_out_discount
      assert_equal reservation.subtotal_amount, @transactable.quantity * @transactable.action_type.pricing.price * (1 - @transactable.action_type.pricing.book_it_out_discount / 100.to_f)
    end

    should 'not create reservation with discount and wrong quantity' do
      @params[:order].merge!(quantity: 7)

      post :create, @params
      assert_redirected_to @transactable.decorate.show_path
      assert assigns(:order).errors.full_messages.include?(I18n.t('reservations_review.errors.book_it_out_not_available'))
    end

    should 'not create reservation with discount if it is turned off' do
      @transactable.transactable_type.event_booking.pricing.update_attributes! allow_book_it_out_discount: false
      @transactable.event_booking.pricing.update_attributes! has_book_it_out_discount: false

      post :create, @params
      assert_response 302
      assert assigns(:order).errors.full_messages.include?(I18n.t('reservations_review.errors.book_it_out_not_available'))
    end

    should 'create reservation without dates' do
      @transactable = FactoryGirl.create(:subscription_transactable)

      post :create, order_params_invalid_for(@transactable).deep_merge(order: { book_it_out: 'true' })

      assert_redirected_to @transactable.decorate.show_path
    end
  end

  context 'Exclusive Price' do
    setup do
      @transactable = FactoryGirl.create(:transactable, :fixed_price)
      @params = order_params_for(@transactable)
      next_available_occurrence = @transactable.next_available_occurrences.first[:id].to_i
      @params[:order].merge!(dates: next_available_occurrence, quantity: 10, exclusive_price: 'true')
    end

    should 'create reservation with exclusive price' do
      post :create, @params
      reservation = Reservation.last
      assert_redirected_to order_checkout_path(Reservation.last)
      # assert_equal reservation.exclusive_price, @transactable.action_type.pricing.exclusive_price
      assert_equal reservation.subtotal_amount, @transactable.action_type.pricing.exclusive_price
      assert_not_equal reservation.subtotal_amount, @transactable.quantity * @transactable.action_type.pricing.price
    end

    should 'not create reservation with discount if it is turned off' do
      @transactable.transactable_type.event_booking.pricing.update_attributes! allow_exclusive_price: false
      @transactable.event_booking.pricing.update_attributes! has_exclusive_price: false
      post :create, @params
      assert_response 302
      assert assigns(:order).errors.full_messages.include?(I18n.t('reservations_review.errors.exclusive_price_not_available'))
    end
  end

  # TODO: Uncomment after adding price_per_unit_for action_types
  # context 'Price per unit' do
  #   setup do
  #     @transactable = FactoryGirl.create(:transactable, :fixed_price)
  #     @params = order_params_for(@transactable)
  #     next_available_occurrence = @transactable.next_available_occurrences.first[:id].to_i
  #     @params[:order].merge!({ dates: next_available_occurrence, quantity: 11.23 })
  #   end

  #   should 'create reservation with price per unit' do
  #     post :create, @params
  #     reservation = Reservation.last
  #     assert_redirected_to booking_successful_dashboard_user_reservation_path(Reservation.last)
  #     assert_equal reservation.subtotal_amount, @transactable.action_type.pricing.price * @params[:order][:quantity]
  #     assert_equal 11.23, reservation.quantity
  #   end
  # end

  private

  def order_params_for(transactable)
    {
      listing_id: transactable.id,
      order: {
        transactable_id: transactable.id,
        dates: [Chronic.parse('Monday')],
        quantity: '1',
        transactable_pricing_id: transactable.action_type.pricings.first.id
      }
    }
  end

  def order_params_invalid_for(transactable)
    {
      listing_id: transactable.id,
      order: {
        transactable_id: transactable.id,
        dates: '',
        quantity: '',
        transactable_pricing_id: transactable.action_type.pricings.first.id
      }
    }
  end

  # def object_hash_for(reservation)
  #   {
  #     booking_desks: reservation.quantity,
  #     booking_days: reservation.total_days,
  #     booking_currency: reservation.currency,
  #     booking_total: reservation.total_amount_dollars,
  #     location_address: reservation.location.address,
  #     location_suburb: reservation.location.suburb,
  #     location_city: reservation.location.city,
  #     location_state: reservation.location.state,
  #     location_country: reservation.location.country,
  #     location_postcode: reservation.location.postcode
  #   }
  # end
end
