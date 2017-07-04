class DataUpload < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :importable, -> { with_deleted }, polymorphic: true
  belongs_to :uploader, -> { with_deleted }, class_name: 'User'
  belongs_to :target, -> { with_deleted }, polymorphic: true
  serialize :parse_summary, Hash

  mount_uploader :csv_file, DataImportFileUploader
  mount_uploader :xml_file, DataImportFileUploader
  validates :csv_file, presence: true, file_size: { less_than_or_equal_to: 50.megabytes.to_i }

  store :options, accessors: %i(send_invitational_email sync_mode enable_rfq default_shipping_category_id), coder: Hash
  scope :for_importable, -> (importable) { where(importable_type: importable.class.name, importable_id: importable.id) }

  state_machine :state, initial: :queued do
    event :process do
      transition [:queued, :failed] => :processing
    end

    event :queue do
      transition any => :queued
    end

    event :import do
      transition [:queued, :processing] => :importing
    end

    event :finish do
      transition importing: :succeeded
    end

    event :finish_with_validation_errors do
      transition importing: :partially_succeeded
    end

    event :failure do
      transition any => :failed
    end
  end

  %w(sync_mode send_invitational_email enable_rfq).each do |attr|
    define_method attr do
      ActiveRecord::Type::Boolean.new.type_cast_from_database(attributes['options'][attr])
    end
  end

  def default_shipping_category_id
    attributes['options']['default_shipping_category_id'].to_i
  end

  def should_be_monitored?
    queued? || processing? || importing?
  end

  def to_liquid
    @data_upload_drop ||= DataUploadDrop.new(self)
  end
end
