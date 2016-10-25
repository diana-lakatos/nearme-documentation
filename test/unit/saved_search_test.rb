require 'test_helper'

class SavedSearchTest < ActiveSupport::TestCase
  context '#unseen_results' do
    setup do
      travel_to Time.zone.now do
        @saved_search = create(:saved_search, created_at: 3.days.ago)
        4.times do |n|
          log = @saved_search.alert_logs.create(results_count: n + 1)
          log.update_column :created_at, n.days.ago
        end
      end
    end

    should 'return sum of not viewed results' do
      assert_equal 6, @saved_search.unseen_results
    end
  end

  context '#change_sort' do
    should 'change sorting to created_at desc' do
      saved_search = create(:saved_search, query: '?loc=Auckland&sort=relevance&query=&transactable_type_id=1&buyable=false&sort=something')
      assert_equal '?loc=Auckland&query=&transactable_type_id=1&buyable=false&sort=created_at_desc', saved_search.query
    end

    should 'chnage sorting to created_at desc with empty existing sort too' do
      saved_search = create(:saved_search, query: '?loc=Auckland&sort=relevance&query=&transactable_type_id=1&buyable=false&sort=')
      assert_equal '?loc=Auckland&query=&transactable_type_id=1&buyable=false&sort=created_at_desc', saved_search.query
    end

    should 'chnage sorting to created_at desc with multi field sort' do
      saved_search = create(:saved_search, query: '?loc=Auckland&sort=relevance_asc,distance_desc&query=&transactable_type_id=1&buyable=false&sort=')
      assert_equal '?loc=Auckland&query=&transactable_type_id=1&buyable=false&sort=created_at_desc', saved_search.query
    end

    should 'chnage sorting to created_at desc with multi field sort with 2 params' do
      saved_search = create(:saved_search, query: '?loc=Auckland&sort=relevance_asc,distance_desc&query=&transactable_type_id=1&buyable=false&sort=relevance_asc,distance_desc')
      assert_equal '?loc=Auckland&query=&transactable_type_id=1&buyable=false&sort=created_at_desc', saved_search.query
    end
  end
end
