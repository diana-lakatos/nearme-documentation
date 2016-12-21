FactoryGirl.define do
  factory :stripe_connect_merchant_account_owner, class: 'MerchantAccountOwner::StripeConnectMerchantAccountOwner' do
    dob_formated { (Date.today - 20.years).strftime('%m-%d-%Y') }
    document { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
    first_name 'John'
    last_name 'Rambo'
    business_tax_id '440-94-3290'
    personal_id_number '440-94-3290'
  end
end
