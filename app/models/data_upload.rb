class DataUpload < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :transactable_type
  belongs_to :uploader, class_name: 'User'
  serialize :parse_summary, Hash

  mount_uploader :csv_file, DataImportFileUploader
  mount_uploader :xml_file, DataImportFileUploader
  validates_presence_of :csv_file

  store :options, accessors: [ :send_invitational_email ], coder: Hash

end
