class PaymentGateway < ActiveRecord::Base
  validates :name, :settings, :active_merchant_class, presence: true
  serialize :settings, Hash

  before_save :set_method_name

  has_many :instance_payment_gateways, dependent: :destroy

  scope :requires_company_onboarding, -> { where(requires_company_onboarding: true) }

  def set_method_name
    self.method_name = name.downcase.gsub(" ", "_")
  end

  def self.supported_at(alpha2_country_code)
    self.all.select { |p| p.supported_countries.include?(alpha2_country_code) }
  end

  def self.countries
    self.all.map { |p| p.supported_countries }.flatten.uniq
  end
end
