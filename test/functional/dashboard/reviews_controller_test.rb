require 'test_helper'

class Dashboard::ReviewsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @reservation = FactoryGirl.create(:past_reservation, user: @user)
    @current_instance = PlatformContext.current.instance
    @current_instance.rating_systems.update_all(active: true)
  end

  context '#index' do
    should "get index" do
      get :index
      assert_response :success
      assert_includes assigns(:owner_reservations), @reservation
      assert_includes assigns(:seller_reservations), @reservation
      assert_includes assigns(:product_reservations), @reservation
      assert_empty assigns(:buyer_reservations)
      assert_empty assigns(:creator_reservations)
      assert_nil assigns(:seller_reviews)
      assert_nil assigns(:product_reviews)
      assert_nil assigns(:buyer_reviews)
    end
  end

  context '#create' do
    should 'respond with success' do
      post :create, review: {rating: 5, object: 'product', reservation: @reservation, user: @user}
      assert_response :success
    end

    should 'respond with failure if rating is blank' do
      post :create, review: {rating: '', object: 'product', reservation: @reservation, user: @user}
      assert_response 422
    end
  end

  context '#update' do
    setup do
      @review = FactoryGirl.create(:review, reservation: @reservation, user: @user)
    end

    should 'respond with success' do
      put :update, id: @review.id, review: {rating: 3}
      assert_response :success
    end

    should 'respond with failure' do
      put :update, id: @review.id, review: {rating: ''}
      assert_response 422
    end
  end

  context '#destroy' do
    setup do
      @review = FactoryGirl.create(:review, reservation: @reservation, user: @user)
    end

    should 'redirect to dashboard_reviews_path' do
      delete :destroy, id: @review.id
      assert_redirected_to dashboard_reviews_path
    end
  end
end