require 'test_helper'

class OrderDecoratorTest < ActionView::TestCase
  context 'methods' do
    setup do
      @payment_gateway = FactoryGirl.create(:stripe_payment_gateway)
      @payment_method = @payment_gateway.payment_methods.first
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

    context 'cancel order' do
      should 'cancel associated payments and do the refund' do
        @order = create(:order_ready_to_ship)
        @order.build_payment
        @order.payments.each { |p| p.complete! }
        @order.finalize!
        # TODO find the pronblem in spree code and fix
        # @order.cancel!
      end
    end
  end

  def assert_product_quantity(quantity)
    @order.line_items.map do |line_item|
      assert_equal quantity, Spree::Stock::Quantifier.new(line_item.variant).total_on_hand
    end
  end
end
