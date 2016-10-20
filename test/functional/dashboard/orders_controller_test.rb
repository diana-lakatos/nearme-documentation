require 'test_helper'

class Dashboard::OrdersControllerTest < ActionController::TestCase
  context 'GET orders' do
    setup do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @company = FactoryGirl.create(:company_in_auckland, creator_id: @user.id)
      @location = FactoryGirl.create(:location_in_auckland)
      @transactable = FactoryGirl.create(:transactable, location: @location)
      @company.locations << @location
    end

    context 'render view' do
      should 'if no bookings' do
        @instance = FactoryGirl.create(:instance)
        get :index, state: 'unconfirmed'
        assert_response :success
        assert_select '.empty-resultset', "You don't have any orders yet"
      end

      should 'if any upcoming bookings' do
        @reservation = FactoryGirl.create(:future_unconfirmed_reservation, user: @user)
        get :index, state: 'unconfirmed'
        assert_response :success
        assert_select '.order', 1
        dates = @reservation.periods.map { |p| I18n.l(p.date.to_date, format: :short) }.join(' ; ')
        assert_select '.order .dates', dates
      end

      should 'if any archived bookings' do
        FactoryGirl.create(:confirmed_reservation, archived_at: Time.zone.now, user: @user)
        get :index, state: 'archived'
        assert_response :success
        assert_select '.order', 1
      end

      context 'with upcoming reservation' do
        setup do
          @reservation = FactoryGirl.create(:future_unconfirmed_reservation, user: @user)
          get :index, state: 'unconfirmed'
          assert_response :success
          assert_select '.order', 1
        end

        should 'if any upcoming bookings' do
          dates = @reservation.periods.map { |p| I18n.l(p.date.to_date, format: :short) }.join(' ; ')
          assert_select '.order .dates', dates
        end
      end
    end
  end
end
