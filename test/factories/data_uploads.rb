include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :data_upload do
    csv_file { fixture_file_upload(Rails.root.join('test', 'assets', 'data_importer', 'sample_data.csv'), 'text/csv') }
    target { (Instance.first.presence || FactoryGirl.create(:instance)) }
    association :uploader, factory: :user
  end

end
