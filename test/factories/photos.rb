include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :photo do
    association :content, factory: :listing
    image { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
    association :creator, factory: :user
    content_type "Listing"
    caption "Caption"
    image_versions_generated_at Time.zone.now
  end

end
