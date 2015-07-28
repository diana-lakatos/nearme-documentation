require 'test_helper'

class OrderDecoratorTest < ActionView::TestCase
  context 'methods' do
    setup do
      @shipping_category = create(:shipping_category)
      Spree::Stock::Package.any_instance.stubs(:currency).returns("USD")
      @order = create(:order_with_line_items)
      @line_item = @order.line_items.first
      Spree::ZoneMember.any_instance.stubs(:zoneable_id).returns(1)
    end

    context 'process order' do
      should 'decrease line item quantity' do
        assert_equal "cart", @order.state
        assert_product_quantity(10)
        assert @order.next
        assert_equal "address", @order.state
        assert_product_quantity(10)
        # assert @order.next
        # assert_equal "delivery", @order.state
        # assert_product_quantity(10)
        # assert @order.next
        # assert_equal "payment", @order.state
        # assert_product_quantity(10)
        # PaymentGateway::ManualPaymentGateway.new.authorize(@order)
        # assert @order.next
        # assert_equal "complete", @order.state
        # assert_product_quantity(9)
      end
    end
  end

  def assert_product_quantity(quantity)
    @order.line_items.map do |line_item|
      assert_equal quantity, Spree::Stock::Quantifier.new(line_item.variant).total_on_hand
    end
  end
end
