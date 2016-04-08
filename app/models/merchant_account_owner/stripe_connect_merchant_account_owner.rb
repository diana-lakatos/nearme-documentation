class MerchantAccountOwner::StripeConnectMerchantAccountOwner < MerchantAccountOwner

  ADDRESS_ATTRIBUTES = %w(address_country address_state address_city address_postal_code address_line1 address_line2)
  ATTRIBUTES = %w(dob first_name last_name) + ADDRESS_ATTRIBUTES

  include MerchantAccount::Concerns::DataAttributes

  belongs_to :merchant_account, class_name: 'MerchantAccount::StripeConnectMerchantAccount'

  validates_format_of :dob, with: /\d{4}-\d{2}-\d{2}/, message: 'Date of Birth has wrong format', allow_blank: true

  def upload_document(stripe_account_id)
    if attributes['document'] || document.file.try(:path)
      # If it's a SanitizedFile it's local, most likely not yet uploaded, and we use SanitizedFile#path instead
      file_path = document.file.is_a?(CarrierWave::SanitizedFile) ? document.file.path : document.proper_file_path

      Stripe::FileUpload.create(
        {purpose: 'identity_document', file: File.new(open(file_path))},
        {stripe_account: stripe_account_id}
      )
    end
  end

end
