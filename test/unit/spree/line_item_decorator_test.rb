require 'test_helper'

class LineItemDecoratorTest < ActionView::TestCase
  context 'methods' do
    setup do
      @order = create(:order_with_line_items)
      @line_item = @order.line_items.first
    end

    context 'has_seller_reviews?' do
      should 'have no reviews' do
        refute @line_item.has_seller_reviews?
      end

      should 'have no seller reviews' do
        FactoryGirl.create(:review, reviewable: @line_item, object: 'product', instance: @order.instance)
        refute @line_item.has_seller_reviews?
      end

      should 'have seller reviews' do
        FactoryGirl.create(:review, reviewable: @line_item, object: 'seller', instance: @order.instance)
        assert @line_item.has_seller_reviews?
      end
    end

    context 'has_product_reviews?' do
      should 'have no reviews' do
        refute @line_item.has_product_reviews?
      end

      should 'have no seller reviews' do
        FactoryGirl.create(:review, reviewable: @line_item, object: 'product', instance: @order.instance)
        assert @line_item.has_product_reviews?
      end

      should 'have seller reviews' do
        FactoryGirl.create(:review, reviewable: @line_item, object: 'seller', instance: @order.instance)
        refute @line_item.has_product_reviews?
      end
    end
  end
end
