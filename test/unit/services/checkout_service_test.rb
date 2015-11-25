require 'test_helper'

class CheckoutServiceTest < ActiveSupport::TestCase
  context "#build_payment_documents"  do

    context "requirement_ids" do
      setup do
        @documents_upload = FactoryGirl.create(:documents_upload)
        @user = FactoryGirl.create(:user)
        @order = FactoryGirl.create(:order_with_line_items, user: @user)
        @upload_obligation = FactoryGirl.create(:upload_obligation, level: UploadObligation::LEVELS[0], item: @order.line_items.first.product )
        @document_requirement = FactoryGirl.create(:document_requirement, item: @order.line_items.first.product)
        @checkout_service = BuySell::CheckoutService.new(@user, @order, ActionController::Parameters.new({order_id: @order.number, id: "payment"}))
        @checkout_service.build_payment_documents
      end

      should 'returns empty requirement_ids' do
        assert @order.payment_documents.present?
      end
    end

    context "build documents for products without upload obligation and document requirement"  do
      setup do
        PlatformContext.current.instance.create_documents_upload(enabled: true, requirement: DocumentsUpload::REQUIREMENTS[0])
        @documents_upload = FactoryGirl.create(:documents_upload)
        @user = FactoryGirl.create(:user)
        @order = FactoryGirl.create(:order_with_line_items, user: @user)
        @checkout_service = BuySell::CheckoutService.new(@user, @order, ActionController::Parameters.new({order_id: @order.number, id: "payment"}))
        @checkout_service.build_payment_documents
      end

      should 'create document_requirements for product' do
        assert_equal @order.line_items.first.product.document_requirements.length, 1
      end

      should 'create upload_obligation for product' do
        assert @order.line_items.first.product.upload_obligation
      end
    end

  end
end
