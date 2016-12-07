# frozen_string_literal: true
require 'test_helper'

class LongtailApiKeywordListIteratorTest < ActiveSupport::TestCase
  class StubbedEndpoint
    def initialize(*arguments)
    end

    def call(url)
      if url == 'http://api-staging.longtailux.com/keywords/seo?page%5Blimit%5D=20&page%5Boffset%5D=20'
        File.read(File.expand_path('../response_page2.json', __FILE__))
      else
        File.read(File.expand_path('../response.json', __FILE__))
      end
    end
  end

  setup do
    @keyword_list = LongtailApi::KeywordListIterator.new(StubbedEndpoint.new)
  end

  should 'be able to iterate through keywords' do
    assert_equal first_keyword_data, @keyword_list.next
    assert_equal second_keyword_data, @keyword_list.next
    18.times { @keyword_list.next }
    assert_equal last_keyword_data, @keyword_list.next
    assert_nil @keyword_list.next
    assert_nil @keyword_list.next
  end

  protected

  def first_keyword_data
    {
      'type' => 'links', 'id' => '1',
      'attributes' => {
        'name' => 'sublet office space new york', 'slug' => 'sublet-office-space-new-york',
        'url' => "\/workspace\/sublet-office-space-new-york", 'type' => 'SEO',
        'category' => 'New York', 'order' => 1, 'section' => 'keyword'
      }
    }
  end

  def second_keyword_data
    {
      'type' => 'links', 'id' => '2',
      'attributes' => {
        'name' => 'new york warehouse studio for rent near me',
        'slug' => 'new-york-warehouse-studio-for-rent-near-me',
        'url' => "\/workspace\/new-york-warehouse-studio-for-rent-near-me",
        'type' => 'SEO', 'category' => 'New York',
        'order' => 2, 'section' => 'keyword'
      }
    }
  end

  def last_keyword_data
    {

      'type' => 'links', 'id' => '1',
      'attributes' => {
        'name' => 'last keyword', 'slug' => 'last-keyword',
        'url' => "\/workspace\/last-keyword", 'type' => 'SEO',
        'category' => 'New York', 'order' => 1, 'section' => 'keyword'
      }
    }
  end
end
