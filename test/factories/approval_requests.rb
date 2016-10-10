include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :approval_request do
    owner_type 'User'
  end
end
