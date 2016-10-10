FactoryGirl.define do
  factory :payment_document_info, class: 'Attachable::PaymentDocumentInfo' do
    document_requirement
  end
end
