require 'stripe'

class MerchantAccountOwner::StripeConnectMerchantAccountOwner < MerchantAccountOwner
  ADDRESS_ATTRIBUTES = %w(address_country address_state address_city address_postal_code address_line1 address_line2).freeze
  ATTRIBUTES = %w(dob_formated dob first_name last_name) + ADDRESS_ATTRIBUTES

  include MerchantAccount::Concerns::DataAttributes

  belongs_to :merchant_account, class_name: 'MerchantAccount::StripeConnectMerchantAccount'

  # validates_format_of :dob, with: /\d{4}-\d{2}-\d{2}/, if:  Proc.new {|s| !s.us_localization }
  # validates_format_of :dob, with: /\d{2}-\d{2}-\d{4}/, if: Proc.new {|s| s.us_localization }
  validate :validate_dob_formated

  def validate_dob_formated
    if dob_formated.blank?
      errors.add :dob, :blank
    else
      begin
        self.dob = Date.strptime(dob_formated, date_format).strftime(default_date_format).to_s
        self.dob_formated = dob.to_date.strftime(date_format).to_s
      rescue
        errors.add :dob, :invalid
      end
    end
  end

  def upload_document(stripe_account_id)
    if attributes['document'] || document.file.try(:path)
      # If it's a SanitizedFile it's local, most likely not yet uploaded, and we use SanitizedFile#path instead
      file_path = document.file.is_a?(CarrierWave::SanitizedFile) ? document.file.path : document.proper_file_path

      Stripe::FileUpload.create(
        { purpose: 'identity_document', file: File.new(open(file_path)) },
        stripe_account: stripe_account_id
      )
    end
  end

  def dob_date
    return unless dob
    Date.strptime(dob, default_date_format)
  end

  def default_date_format
    '%Y-%m-%d'
  end

  def date_format
    I18n.t('date.formats.stripe') || default_date_format
  end

  def date_format_readable
    date_format.gsub('%Y', 'YYYY').gsub('%m', 'MM').gsub('%d', 'DD')
  end
end
