require 'test_helper_lite'
require 'addressable'
require 'uri'
require 'pry'
require 'rack'

class PageTest < ActiveSupport::TestCase

  def extract(url)
    template.extract(Addressable::URI.parse(url))
  end

  def template
    Addressable::Template.new('http://example.lvh.me:3000/s/{city}/{street}{/extra*}{?query_params*}')
  end

  test 'extract_long url_params 1' do
    url = URI.escape 'http://example.lvh.me:3000/s/Sydney/Claremont Meadows/NWS/storage/some/extra/params/'

    template.extract(Addressable::URI.parse(url)).tap do |result|
      assert_equal result.dig('city'), 'Sydney'
      assert_equal result.dig('street'), 'Claremont Meadows'
      assert result
    end
  end

  test 'extract_short url_params' do
    url = URI.escape 'http://example.lvh.me:3000/s/Sydney/Claremont Meadows//'

    template.extract(Addressable::URI.parse(url)).tap do |result|
      assert result
      assert_equal result.dig('city'), 'Sydney'
      assert_equal result.dig('street'), 'Claremont Meadows'
      assert_equal result.dig('extra'), []
    end
  end
end
