# frozen_string_literal: true
require 'test_helper_lite'
require './lib/api/pagination_links'

class PaginationLinksTest < ActiveSupport::TestCase
  test 'all links' do
    url_helper = ->(params) { "some_url#{params}" }

    result = Api::PaginationLinks.links(url_generator: url_helper, total_pages: 5, current_page: 2, params: {})

    assert_equal(
      result,
      {
        first: 'some_url{:page=>1}',
        last: 'some_url{:page=>5}',
        prev: 'some_url{:page=>1}',
        next: 'some_url{:page=>3}'
      }
    )
  end
end
