require 'test_helper'

class ListingsControllerTest < ActionController::TestCase
  setup do
    @listing = FactoryGirl.create(:transactable, :fixed_price)
    @transactable_type = @listing.transactable_type
  end

  context 'GET #occurrences.json' do
    should 'render json' do
      get :occurrences, id: @listing.id
      assert :success
    end

    should 'have occurrences' do
      get :occurrences, id: @listing.id
      assert 10, JSON.parse(response.body).length
    end
  end

  context '#show' do
    should 'display two content holders' do
      holder = FactoryGirl.create :content_holder, inject_pages: ['service/product_page'], content: '{{ listing.street }} and whatever'
      holder = FactoryGirl.create :content_holder, inject_pages: ['service/product_page'], content: 'This is an id of listing: {{ listing.id }}'
      get :show, id: @listing
      assert response.body.include?("This is an id of listing: #{ @listing.id }")
      assert response.body.include?("#{@listing.location.street} and whatever")
    end

    should 'redirect to search if listing is inactive and there are no other listings' do
      @listing.update_attributes(enabled: false)
      get :show, id: @listing
      assert_response :redirect
      assert_redirected_to search_path(loc: @listing.address, q: @listing.name)
    end

    context 'multiple listings' do
      setup do
        @second_listing = FactoryGirl.create(:transactable, location: @listing.location)
      end

      context 'not searchable listing' do
        should 'show warning if listing is inactive but there is at least one active listing' do
          @listing.update_attributes(draft: Time.now)
          get :show, id: @listing
          assert_response :redirect
          assert_redirected_to @second_listing.decorate.show_path
          assert flash[:warning].include?('This listing is inactive'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
        end

        should 'show warning if user cannot manage listing and there is at least one active listing' do
          @listing.update_attributes(enabled: false)
          get :show, id: @listing
          assert_response :redirect
          assert_redirected_to @second_listing.decorate.show_path
          assert flash[:warning].include?('This listing has been temporarily disabled by the owner'), "Expected #{flash[:warning]} to include 'This listing is inactive'"
        end

        should 'show warning but not redirect if user can manage listing' do
          @listing.update_attributes(enabled: false)
          sign_in @listing.creator
          get :show, id: @listing
          assert_response :success
          assert_not_nil flash[:warning]
        end
      end
    end
  end
end
