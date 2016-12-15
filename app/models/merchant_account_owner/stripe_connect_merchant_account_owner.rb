# frozen_string_literal: true
# frozen_string_literal: true
require 'stripe'

class MerchantAccountOwner::StripeConnectMerchantAccountOwner < MerchantAccountOwner

  ATTRIBUTES = %w(dob_formated dob first_name last_name personal_id_number business_vat_id business_tax_id)

  include MerchantAccount::Concerns::DataAttributes
  has_one :current_address, class_name: 'Address', as: :entity, validate: false
  accepts_nested_attributes_for :current_address

  belongs_to :merchant_account, class_name: 'MerchantAccount::StripeConnectMerchantAccount'
  delegate :iso_country_code, :account_type, to: :merchant_account, allow_nil: true

  validates :last_name, :first_name, presence: true
  validate :validate_dob_formated
  validates :personal_id_number, presence: { if: proc { |m| m.iso_country_code == 'US' } }
  validates :business_tax_id, presence: { if: proc { |m| m.iso_country_code == 'US' && m.account_type == 'company' } }
  validate :validate_document

  def validate_document
    if (attributes['document'] || document.file.try(:path)).blank?
      errors.add(:document, :blank)
    end
  end

  validate :validate_current_address

  def validate_current_address
    return if current_address.blank?

    current_address.parse_address_components!
    current_address.errors.clear

    errors.add(:current_address, :inacurate) if current_address.valid? && current_address.check_address
  end

  after_initialize :build_current_address_if_needed
  def build_current_address_if_needed
    build_current_address unless current_address
  end

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
