require 'test_helper'

class Dashboard::SavedSearchesControllerTest < ActionController::TestCase

  context '#search' do
    setup do
      @saved_search = create(:saved_search, query: '?loc=Auckland&query=&transactable_type_id=1&buyable=false')
      sign_in @saved_search.user
    end

    should 'update saved_search#last_viewed_at' do
      travel_to Time.zone.now do
        get :search, id: @saved_search.id
        assert_equal Time.zone.now.to_i, @saved_search.reload.last_viewed_at.to_i
      end
    end

    should 'redirect to search page' do
      get :search, id: @saved_search.id
      assert_redirected_to @saved_search.path
    end
  end
end
