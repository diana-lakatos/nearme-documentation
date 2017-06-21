# frozen_string_literal: true
module Attachable
  class MerchantAccountOwnerAttachement < Attachable::Attachment
    # @!method file
    #   @return [MerchantAccountOwnerDocumentUploader]
    mount_uploader :file, ::MerchantAccountOwnerDocumentUploader

    validates :file, presence: true, file_size: { less_than_or_equal_to: 50.megabytes.to_i }

    self.per_page = 20

    scope :uploaded_by, ->(user_id) { where(user_id: user_id) }
    scope :not_uploaded_by, ->(user_id) { where.not(user_id: user_id) }

    def path
      # If it's a SanitizedFile it's local, most likely not yet uploaded, and we use SanitizedFile#path instead
      file.file.is_a?(CarrierWave::SanitizedFile) ? file.path : file.proper_file_path
      # TODO refactor https://near-me.atlassian.net/browse/NM-7961
    end

    def to_liquid
      @drop ||= Attachable::MerchantAccountOwnerAttachementDrop.new(self)
    end
  end
end
