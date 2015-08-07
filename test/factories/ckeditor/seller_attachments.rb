FactoryGirl.define do
  factory :seller_attachment do
    data { fixture_file_upload(Rails.root.join('test', 'assets', 'hello.pdf'), 'image/jpeg') }
    assetable { FactoryGirl.create(:transactable) }
    user
    access_level 'all'
    instance { Instance.first || FactoryGirl.create(:instance) }
  end
end
