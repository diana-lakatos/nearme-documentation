require 'test_helper'

class CheckoutServiceTest < ActiveSupport::TestCase
  context "#build_payment_documents"  do
    setup do
      @documents_upload = FactoryGirl.create(:documents_upload)
      @user = FactoryGirl.create(:user)
      @order = FactoryGirl.create(:order_with_line_items, user: @user)
      @upload_obligation = FactoryGirl.create(:upload_obligation, level: UploadObligation::LEVELS[0], item: @order.line_items.first.product )
      @document_requirement = FactoryGirl.create(:document_requirement, item: @order.line_items.first.product)
      @checkout_service = BuySell::CheckoutService.new(@user, @order, {order_id: @order.number, id: "payment"})
      @checkout_service.build_payment_documents
    end

    should 'returns empty requirement_ids' do
      assert_equal @order.payment_documents.size, 1
    end
  end
end