# frozen_string_literal: true
require 'test_helper'

class LongtailApiKeywordTest < ActiveSupport::TestCase
  should 'return body' do
    @endpoint = mock
    @endpoint.stubs(:call)
             .with('/search/seo/sublet-office-space-new-york')
             .returns(File.read(File.expand_path('../keyword_response.json', __FILE__)))
    assert_equal %w(data included meta), LongtailApi::Keyword.new(endpoint: @endpoint, data: keyword_data, campaign: 'seo').body.keys
  end

  should 'return slug' do
    assert_equal 'sublet-office-space-new-york',
                 LongtailApi::Keyword.new(endpoint: nil, data: keyword_data, campaign: 'seo').slug
  end

  should 'return path' do
    assert_equal 'workspace/sublet-office-space-new-york',
                 LongtailApi::Keyword.new(endpoint: nil, data: keyword_data, campaign: 'seo').path
  end

  should 'return id'  do
    assert_equal '1', LongtailApi::Keyword.new(endpoint: nil, data: keyword_data, campaign: 'seo').id
  end

  protected

  def keyword_data
    {
      'type' => 'links', 'id' => '1',
      'attributes' => {
        'name' => 'sublet office space new york', 'slug' => 'sublet-office-space-new-york',
        'url' => '/workspace/sublet-office-space-new-york', 'type' => 'SEO',
        'category' => 'New York', 'order' => 1, 'section' => 'keyword'
      }
    }
  end
end
