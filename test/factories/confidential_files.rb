include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :confidential_file do
    file { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
    caption "Caption"
  end

end
