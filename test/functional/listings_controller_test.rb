require 'test_helper'

class ListingsControllerTest < ActionController::TestCase

  context 'GET #occurrences.json' do
    setup do
      @listing = FactoryGirl.create(:transactable)
    end

    
    should 'render json' do
      get :occurrences, id: @listing.id
      assert :success
    end

    should 'have occurrences' do
      11.times { FactoryGirl.create(:transactable) }
      get :occurrences, id: @listing.id
      assert 10, JSON.parse(response.body).length
    end
  end
end

