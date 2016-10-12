require 'test_helper'

class Attachable::PaymentDocumentTest < ActiveSupport::TestCase
  should have_one(:payment_document_info)

  context 'scopes' do
    setup do
      @user1 = create(:user)
      @user2 = create(:user)
      @doc1 = create(:attachable_payment_document, user_id: @user1.id)
      @doc2 = create(:attachable_payment_document, user_id: @user2.id)
    end

    should '.uploaded_by' do
      docs = Attachable::PaymentDocument.uploaded_by(@user2).pluck(:id)

      refute docs.include?(@doc1.id)
      assert docs.include?(@doc2.id)
    end

    should '.not_uploaded_by' do
      docs = Attachable::PaymentDocument.not_uploaded_by(@user1).pluck(:id)

      refute docs.include?(@doc1.id)
      assert docs.include?(@doc2.id)
    end
  end
end
