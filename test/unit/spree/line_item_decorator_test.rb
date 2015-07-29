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
        rs = FactoryGirl.create(:rating_system, subject: RatingConstants::TRANSACTABLE)
        FactoryGirl.create(:review, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s, rating_system_id: rs.id, instance: @order.instance)
        refute @line_item.has_seller_reviews?
      end

      should 'have seller reviews' do
        rs = FactoryGirl.create(:rating_system, subject: RatingConstants::HOST)
        FactoryGirl.create(:review, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s, rating_system_id: rs.id, instance: @order.instance)
        assert @line_item.has_seller_reviews?
      end
    end

    context 'has_product_reviews?' do
      should 'have no reviews' do
        refute @line_item.has_product_reviews?
      end

      should 'have no seller reviews' do
        rs = FactoryGirl.create(:rating_system, subject: RatingConstants::TRANSACTABLE)
        FactoryGirl.create(:review, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s, rating_system_id: rs.id, instance: @order.instance)
        assert @line_item.has_product_reviews?
      end

      should 'have seller reviews' do
        rs = FactoryGirl.create(:rating_system, subject: RatingConstants::HOST)
        FactoryGirl.create(:review, reviewable_id: @line_item.id, reviewable_type: @line_item.class.to_s, rating_system_id: rs.id, instance: @order.instance)
        refute @line_item.has_product_reviews?
      end
    end
  end
end
