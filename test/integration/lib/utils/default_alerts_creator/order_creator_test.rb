require 'test_helper'

class Utils::DefaultAlertsCreator::OrderCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @order_creator = Utils::DefaultAlertsCreator::OrderCreator.new
  end

  should 'create all' do
    @order_creator.expects(:create_confirm_email!).once
    @order_creator.expects(:create_cancel_email!).once
    @order_creator.expects(:create_notify_seller_email!).once
    @order_creator.expects(:create_notify_shipped_email!).once
    @order_creator.expects(:create_notify_approved_email!).once
    @order_creator.create_all!
  end

  context 'methods' do
    setup do
      stub_mixpanel
      @platform_context = PlatformContext.current
      @instance = @platform_context.instance
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
    end

    should 'created order' do
      @order_creator.create_confirm_email!
      @order = FactoryGirl.create(:completed_order_with_totals)
      @user = @order.user
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Finalized, @order.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_equal 'Order Confirmation', mail.subject
      assert_contains 'Dear Customer', mail.html_part.body
      assert_equal [@user.email], mail.to
      assert_contains 'Shipping:', mail.html_part.body
      @order.line_items.each do |item|
        assert_contains "#{item.variant.sku} #{item.variant.product.name} #{ item.variant.options_text } #{item.quantity} @ #{item.single_money} = #{item.display_amount}", mail.html_part.body
      end
      assert_not_contains 'Liquid error', mail.html_part.body
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'cancel email' do
      @order_creator.create_cancel_email!
      @order = FactoryGirl.create(:completed_order_with_totals)
      @user = @order.user
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Cancelled, @order.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_equal 'Cancellation of Order', mail.subject
      assert_contains 'Your order has been CANCELLED', mail.html_part.body
      assert_equal [@user.email], mail.to
      @order.line_items.each do |item|
        assert_contains "#{item.variant.sku} #{item.variant.product.name} #{ item.variant.options_text } #{item.quantity} @ #{item.single_money} = #{item.display_amount}", mail.html_part.body
      end
      assert_not_contains 'Liquid error', mail.html_part.body
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    should 'shipped email' do
      @order_creator.create_notify_shipped_email!
      @order = FactoryGirl.create(:completed_order_with_totals)
      @user = @order.user
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Shipped, @order.shipments.first.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_equal "Shipment Notification #{@order.number}", mail.subject
      assert_contains 'Your order has been shipped', mail.html_part.body
      assert_equal [@user.email], mail.to
      @order.shipments.first.manifest.each do |item|
        assert_contains "#{ item.variant.sku } #{ item.variant.product.name} #{item.variant.options_text}", mail.html_part.body
      end
      assert_not_contains 'Tracking Information', mail.html_part.body
      assert_not_contains 'Liquid error', mail.html_part.body
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

    context 'notify host' do

      should 'not include buyer email if not manual' do
        @order_creator.create_notify_seller_email!
        @order = FactoryGirl.create(:completed_order_with_totals)
        @user = @order.company.creator
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Finalized, @order.id)
        end
        mail = ActionMailer::Base.deliveries.last

        assert_equal 'New Order', mail.subject
        assert_contains 'Dear Seller', mail.html_part.body
        assert_equal [@user.email], mail.to
        assert @order.line_items.count > 0, 'Testing order email without line items!'
        assert_contains 'Shipping:', mail.html_part.body
        @order.line_items.each do |item|
          assert_contains "#{item.variant.sku} #{item.variant.product.name} #{ item.variant.options_text } #{item.quantity} @ #{item.single_money} = #{item.display_amount}", mail.html_part.body
        end
        assert_not_contains "Email to which invoice should be sent: #{@order.user.email}", mail.html_part.body
        assert_not_contains 'Liquid error', mail.html_part.body
        assert_contains 'href="http://custom.domain.com/', mail.html_part.body
        assert_not_contains 'href="http://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body
      end

      should 'include buyer email if manual' do
        @order_creator.create_notify_seller_email!
        @order = FactoryGirl.create(:completed_order_with_totals)
        @order.update_attribute(:payment_method_id, FactoryGirl.create(:manual_payment_gateway).payment_methods.first.id)
        @user = @order.company.creator
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Finalized, @order.id)
        end
        mail = ActionMailer::Base.deliveries.last
        assert_contains "Email to which invoice should be sent: #{@order.user.email}", mail.html_part.body
      end
    end

    should 'approved order' do
      @order_creator.create_notify_approved_email!
      @order = FactoryGirl.create(:completed_order_with_totals)
      @user = @order.user
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::OrderWorkflow::Approved, @order.id)
      end
      mail = ActionMailer::Base.deliveries.last

      assert_equal "Approval of Order #{@order.number}", mail.subject
      assert_contains 'Dear Customer', mail.html_part.body
      assert_equal [@user.email], mail.to
      assert_contains 'has been approved', mail.html_part.body
      @order.line_items.each do |item|
        assert_contains "#{item.variant.sku} #{item.variant.product.name} #{ item.variant.options_text } #{item.quantity} @ #{item.single_money} = #{item.display_amount}", mail.html_part.body
      end
      assert_not_contains 'Liquid error', mail.html_part.body
      assert_contains 'href="http://custom.domain.com/', mail.html_part.body
      assert_not_contains 'href="http://example.com', mail.html_part.body
      assert_not_contains 'href="/', mail.html_part.body
    end

  end

end

