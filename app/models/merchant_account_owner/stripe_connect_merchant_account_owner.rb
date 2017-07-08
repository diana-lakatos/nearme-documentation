# frozen_string_literal: true
# frozen_string_literal: true
require 'stripe'

class MerchantAccountOwner::StripeConnectMerchantAccountOwner < MerchantAccountOwner
  ATTRIBUTES = %w(dob_formated dob first_name last_name).freeze

  include MerchantAccount::Concerns::DataAttributes
  has_one :current_address, class_name: 'Address', as: :entity, validate: false
  has_many :attachements, class_name: '::Attachable::MerchantAccountOwnerAttachement', validate: true, as: :attachable
  belongs_to :merchant_account, class_name: 'MerchantAccount::StripeConnectMerchantAccount'

  delegate :iso_country_code, :payment_gateway, to: :merchant_account, allow_nil: true

  validates :last_name, :first_name, presence: true
  validate :validate_dob_formated
  validate :validate_current_address

  after_initialize :build_current_address_if_needed

  accepts_nested_attributes_for :current_address
  accepts_nested_attributes_for :attachements

  def upload_document(stripe_account_id)
    if attachements.any?
      response = Stripe::FileUpload.create(
        { purpose: 'identity_document', file: File.new(File.open(photo_id_file.path)) },
        stripe_account: stripe_account_id
      )
      response
    end
  end

  def photo_id_file
    @photo_id_file ||= CombinedImage.new(attachements.map(&:path)).file
  end

  def tmp_attachement_path
    File.join(Rails.root, 'tmp', "owner_#{id}_photo_id.jpg")
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

  private

  def build_current_address_if_needed
    build_current_address unless current_address
  end

  def validate_current_address
    return if current_address.blank?

    current_address.parse_address_components! unless current_address.raw_address?
    current_address.errors.clear
    errors.add(:current_address, :inacurate) if current_address.valid? && current_address.check_address
  end

  def validate_attachements
    return true if payment_gateway.nil?
    return true unless (payment_gateway.config[:validate_merchant_account] || []).include?(:attachements)

    errors.add(:attachements, :blank) if attachements.size < 2
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
end
