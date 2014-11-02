require 'test_helper'

class Spree::Product::SearchFetcherTest < ActiveSupport::TestCase

  setup do
    Transactable.destroy_all
    @taxon1 = FactoryGirl.create(:taxon, name: 'taxon 1')
    @taxon2 = FactoryGirl.create(:taxon, name: 'taxon 2')

    @product1 = FactoryGirl.create(:product, name: 'product one')
    @product1.taxons << @taxon1
    @product2 = FactoryGirl.create(:product, name: 'product two')
    @product2.taxons << @taxon2

    @filters = {}
  end

  context 'filters' do

    should 'find products with specified taxon' do
      @filters.merge!({ taxon: @taxon1.permalink })
      assert_equal [@product1], Spree::Product::SearchFetcher.new(@filters).products
    end

    should 'find products with any keyword from query' do
      @filters.merge!({ query: 'product' })
      assert_equal [@product1, @product2].sort, Spree::Product::SearchFetcher.new(@filters).products.sort
    end
  end
end
