require 'test_helper'

class ProductDecoratorTest < ActionView::TestCase
   context 'new product creation' do

    setup do
      @product = create(:base_product)
    end

    should 'have the same company assigned to product and master variant' do
      assert @product.company.class, Company
      assert @product.company, @product.master.company
    end

    context 'search_by_query' do

      should 'return relation' do
        assert_equal Spree::Product.search_by_query([:name], nil).approved.to_sql, Spree::Product.approved.to_sql
        assert_equal Spree::Product.search_by_query([:name], '').approved.to_sql, Spree::Product.approved.to_sql
      end

      should 'return search statement' do
        assert_not_equal Spree::Product.search_by_query([:name], 'super query').approved.to_sql, Spree::Product.approved.to_sql
      end

    end
  end
end
