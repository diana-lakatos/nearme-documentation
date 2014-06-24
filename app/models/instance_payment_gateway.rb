class InstancePaymentGateway < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  attr_accessible :payment_gateway_id, :live_settings, :test_settings, :country
  attr_accessor :country

  serialize :test_settings, Hash
  serialize :live_settings, Hash

  attr_encrypted :test_settings, :live_settings, :key => DesksnearMe::Application.config.secret_token, marshal: true

  validate :payment_gateway_id, :test_settings, :live_settings, presence: true

  has_many :country_instance_payment_gateways, dependent: :destroy
  belongs_to :instance
  belongs_to :payment_gateway

  delegate :name, to: :payment_gateway
  delegate :supported_countries, to: :payment_gateway

  after_initialize :default_values
  after_save :set_country_config

  def set_country_config
    if country.present?
      country_instance_payment_gateway = self.instance.country_instance_payment_gateways.where(country_alpha2_code: country).first_or_initialize
      country_instance_payment_gateway.instance_payment_gateway_id = self.id
      country_instance_payment_gateway.save!
    end
  end

  def default_values
    [:test_settings, :live_settings].each do | method |
      if self.send(method).nil?
        self.send("#{method}=", payment_gateway.settings) if payment_gateway.present?
      end
    end
  end

  def self.get_settings_for(method_name, key=nil, mode=nil)
    payment_gateway = PaymentGateway.find_by_method_name(method_name)
    instance_payment_gateway = self.where(payment_gateway_id: payment_gateway.id).first

    return self.settings_for_key(payment_gateway.settings, key) if instance_payment_gateway.nil?

    if mode.nil?
      settings = instance_payment_gateway.instance.test_mode? ? instance_payment_gateway.test_settings : instance_payment_gateway.live_settings
    else
      settings = instance_payment_gateway.send(:"#{mode}_settings")
    end

    settings_for_key(settings.with_indifferent_access, key)
  end

  def self.settings_for_key(settings, key)
    case key
    when String
      settings[key.to_sym]
    when Symbol
      settings[key]
    when Array
      settings.delete_if { |k| !key.include?(k) }
    when NilClass
      settings.symbolize_keys
    else
      return String.new
    end
  end

  def self.set_settings_for(method_name, settings, mode=nil)
    payment_gateway = PaymentGateway.find_by_method_name(method_name)
    instance_payment_gateway = self.where(payment_gateway_id: payment_gateway.id).first

    if instance_payment_gateway.nil?
      instance_payment_gateway = create(
        payment_gateway_id: payment_gateway.id,
        live_settings: payment_gateway.settings,
        test_settings: payment_gateway.settings
      )
    end

    mode = instance_payment_gateway.instance.payment_gateway_mode if mode.nil?

    settings = instance_payment_gateway.send(:"#{mode.to_s}_settings").merge(settings)
    instance_payment_gateway.update_attribute(:"#{mode.to_s}_settings", settings)
  end

  def self.sort_by_country_support
    all.sort { |a,b| a.supported_countries.count <=> b.supported_countries.count }
  end

end
