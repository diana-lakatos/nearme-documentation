FactoryGirl.define do
  factory :listing_message do
    listing_id { Listing.first.try(:id).presence || FactoryGirl.create(:listing).id }
    author_id { User.first.try(:id).presence || FactoryGirl.create(:user).id }
    owner_id { User.first.try(:id).presence || FactoryGirl.create(:user).id }
    body "Hey whats up"
  end
end
