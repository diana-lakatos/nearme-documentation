FactoryGirl.define do
  factory :documents_upload do
    requirement { DocumentsUpload::REQUIREMENTS.sample }
    enabled false
    instance
  end

  factory :enabled_documents_upload, parent: :documents_upload do
    enabled true
  end
end
