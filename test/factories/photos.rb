include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :photo do
    association :content, factory: :listing
    image { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
    association :creator, factory: :user
    content_type "Listing"
    caption "Caption"
    image_versions_generated_at Time.zone.now

    factory :demo_photo do
      image { fixture_file_upload(Dir.glob(Rails.root.join('db', 'seeds', 'demo', 'assets', 'listing_photos', '*')).sample, 'image/jpeg') }
      image_versions_generated_at Time.zone.now
    end
  end 

end
