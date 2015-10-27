require 'test_helper'

class Spree::Product::SearchFetcherTest < ActiveSupport::TestCase

  setup do
    Transactable.destroy_all
    @category1 = FactoryGirl.create(:category, name: 'category 1')
    @category2 = FactoryGirl.create(:category, name: 'category 2')
    @product_type = FactoryGirl.create(:product_type, :with_custom_attribute)
    @product1 = FactoryGirl.create(:product, name: 'product one', product_type: @product_type)
    @product1.categories << @category1
    @product2 = FactoryGirl.create(:product, name: 'product two', product_type: @product_type)
    @product2.categories << @category2

    @irrelevant_product = FactoryGirl.create(:product, name: 'product irrelevant', product_type: FactoryGirl.create(:product_type))
    @irrelevant_product.categories << @category1

    @filters = {transactable_type_id: @product_type.id}
  end

  context 'filters' do

    should 'find products with specified category' do
      @filters.merge!({ category_ids: @category1.id.to_s })
      assert_equal [@product1], Spree::Product::SearchFetcher.new(@filters, @product1.product_type).products
    end

    should 'find products with any keyword from query' do
      @filters.merge!({ query: 'product' })
      assert_equal [@product1, @product2].sort, Spree::Product::SearchFetcher.new(@filters, @product1.product_type).products.sort
    end

    context 'extra_properties' do
      setup do
        @product3 = FactoryGirl.create(:product, name: 'product three', product_type: @product_type)
        @product3.extra_properties['manufacturer'] = "Bosh"
        @product3.save!
      end

      should 'find products with any keyword from query in properties' do
        @filters.merge!({ query: 'bosh' })
        assert_equal [@product3], Spree::Product::SearchFetcher.new(@filters, @product3.product_type).products
      end

      should 'find products with any keyword from query in properties and name' do
        @filters.merge!({ query: 'bosh product' })
        assert_equal [@product1, @product2, @product3].sort, Spree::Product::SearchFetcher.new(@filters, @product1.product_type).products.sort
      end
    end
  end
end
