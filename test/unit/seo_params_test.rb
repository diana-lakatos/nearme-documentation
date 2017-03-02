# frozen_string_literal: true
require 'test_helper_lite'
require './app/models/seo_params'

class SeoParamsTest < ActiveSupport::TestCase
  test 'humanize slugs' do
    params = { language: nil, controller: 'pages', action: 'show', slug: 'desks', slug2: 'san-francisco' }

    result = SeoParams.create(params)

    assert_equal result, slug: 'desks', slug2: 'san francisco'
  end
end
