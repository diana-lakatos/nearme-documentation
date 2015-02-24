FactoryGirl.define do
  factory :upload_obligation do
    level UploadObligation::LEVELS.sample
    item { FactoryGirl.create(:transactable) }
  end
end
