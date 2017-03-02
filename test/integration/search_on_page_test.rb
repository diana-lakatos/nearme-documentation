require 'test_helper'

# Test search that build into Page with Graphql
class SearchOnPageTest < ActionDispatch::IntegrationTest
  setup do
    enable_elasticsearch!
  end

  teardown do
    disable_elasticsearch!
  end

  context 'with search page' do
    setup do
      @tt = FactoryGirl.create(:transactable_type)
      create_graph_query(@tt)
      template = "
      {% query_graph 'search', result_name: g, query: seo_params.slug2 %}
      hola
      {{ g }}
      {{ params }}
      {{ seo_params }}
      {% for t in g.search_transactables.results %}
        {{ t.name }}
      {% endfor %}
      "
      @page = FactoryGirl.create(:page, path: 'desks', slug: 'desks', content: template)
      @desk_in_auckland = FactoryGirl.create(:listing_in_auckland, transactable_type: @tt)
      @desk_in_sanfrancisco = FactoryGirl.create(:listing_in_san_francisco, transactable_type: @tt)
      wait_for_elastic_index
    end

    should 'display' do
      get '/desks'

      assert_transactables_in_results [@desk_in_auckland, @desk_in_sanfrancisco]

      get '/desks/san-francisco'

      assert_transactables_in_results [@desk_in_sanfrancisco]
      assert_no_transactables_in_results [@desk_in_auckland]
    end
  end

  def assert_transactables_in_results(transactables)
    assert_response :success
    assert response.body.include?('hola')
    transactables.each do |t|
      assert response.body.include?(t.name), "There is no: #{t.name}"
    end
  end

  def assert_no_transactables_in_results(transactables)
    transactables.each do |t|
      refute response.body.include?(t.name)
    end
  end

  def create_graph_query(transactable_type)
    query = "
      query search($query: String) {
        search_transactables(kind: \"#{transactable_type.name}\", params: {query: $query}) {
          results{
            name
          }
        }
      }"
    FactoryGirl.create(:graph_query, name: 'search', query_string: query)
  end
end
