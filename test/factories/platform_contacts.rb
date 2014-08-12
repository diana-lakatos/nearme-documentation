FactoryGirl.define do
  factory :platform_contact do
    name Faker::Name.name
    email Faker::Internet.email
    company "Test Co."
    comments "I would like to build a marketplace."
    location "Texas"
    previous_research "Looked as various opensource marketplace platforms."
    lead_source "Found you guys on google."
    subscribed true
  end
end

