require 'test_helper'

class Dashboard::ReviewsControllerTest < ActionController::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @company = FactoryGirl.create(:company, creator: @user)
    User.any_instance.stubs(:registration_completed?).returns(true)
    sign_in @user
    @current_instance = PlatformContext.current.instance
    @current_instance.rating_systems.update_all(active: true)
    @reservation = FactoryGirl.create(:past_reservation, user: @user)
  end

  context '#index' do
    should "get index" do
      get :index
      assert_response :success
    end
  end

  context '#create' do
    should 'respond with success' do
      post :create, review: FactoryGirl.attributes_for(:review, object: 'product', user: @user, reviewable_id: @reservation.id, reviewable_type: @reservation.class.name, instance: @current_instance)
      assert_response :success
    end

    should 'respond with failure if rating is blank' do
      post :create, review: FactoryGirl.attributes_for(:review, rating: '', object: 'product', user: @user, reviewable_id: @reservation.id, reviewable_type: @reservation.class.name, instance: @current_instance)
      assert_response 422
    end
  end

  context '#update' do
    setup do
      @review = FactoryGirl.create(:review, object: 'product', user: @user, reviewable_id: @reservation.id, reviewable_type: @reservation.class.name, instance: @current_instance)
    end

    should 'respond with success' do
      put :update, id: @review.id, review: {rating: 3, reviewable_type: @review.reviewable_type, reviewable_id: @review.reviewable_id, instance_id: @current_instance.id}
      assert_response :success
    end

    should 'respond with failure' do
      put :update, id: @review.id, review: {rating: '', reviewable_type: @review.reviewable_type, reviewable_id: @review.reviewable_id, instance_id: @current_instance.id}
      assert_response 422
    end
  end

  context '#destroy' do
    setup do
      @review = FactoryGirl.create(:review, object: 'product', reviewable: @reservation, user: @user, instance: @current_instance)
    end

    should 'redirect to dashboard_reviews_path' do
      delete :destroy, id: @review.id
      assert_redirected_to dashboard_reviews_path
    end
  end
end