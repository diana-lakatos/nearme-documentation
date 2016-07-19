FactoryGirl.define do
  factory :attachable_payment_document, class: 'Attachable::PaymentDocument' do
    attachable { FactoryGirl.create(:purchase, user: user) }
    file { fixture_file_upload(Rails.root.join('test', 'fixtures', 'avatar.jpg')) }
    user
  end
end
