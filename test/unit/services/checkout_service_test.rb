# require 'test_helper'

# class CheckoutServiceTest < ActiveSupport::TestCase
#   context "#build_payment_documents"  do

#     context "requirement_ids" do
#       setup do
#         @documents_upload = FactoryGirl.create(:documents_upload)
#         @user = FactoryGirl.create(:user)
#         @order = FactoryGirl.create(:purchase, user: @user).reload
#         @upload_obligation = FactoryGirl.create(:upload_obligation, level: UploadObligation::LEVELS[0], item: @order.transactable )
#         @document_requirement = FactoryGirl.create(:document_requirement, item: @order.transactable)
#         @checkout_service = BuySell::CheckoutService.new(@user, @order, ActionController::Parameters.new({order_id: @order.number, id: "payment"}))
#         @checkout_service.build_payment_documents
#       end

#       should 'returns empty requirement_ids' do
#         assert @order.payment_documents.present?
#       end
#     end

#     context "build documents for transactables without upload obligation and document requirement"  do
#       setup do
#         PlatformContext.current.instance.create_documents_upload(enabled: true, requirement: DocumentsUpload::REQUIREMENTS[0])
#         @documents_upload = FactoryGirl.create(:documents_upload)
#         @user = FactoryGirl.create(:user)
#         @order = FactoryGirl.create(:purchase, user: @user).reload
#         @checkout_service = BuySell::CheckoutService.new(@user, @order, ActionController::Parameters.new({ id: @order.id }))
#         @checkout_service.build_payment_documents
#       end

#       should 'create document_requirements for transactable' do
#         assert_equal 1, @order.transactable.document_requirements.length
#       end

#       should 'create upload_obligation for transactable' do
#         assert @order.transactable.upload_obligation
#       end
#     end

#   end
# end
