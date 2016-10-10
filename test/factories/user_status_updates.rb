FactoryGirl.define do
  factory :user_status_update do
    text 'myString'
    updateable { FactoryGirl.create(:user) }
    user
  end
end
