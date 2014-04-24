class InstancePaymentGateway < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  attr_accessible :payment_gateway_id, :live_settings, :test_settings
  serialize :test_settings, Hash
  serialize :live_settings, Hash

  attr_encrypted :test_settings, :live_settings, :key => DesksnearMe::Application.config.secret_token, marshal: true
  
  validate :payment_gateway_id, presence: true

  belongs_to :instance
  belongs_to :payment_gateway

  delegate :name, to: :payment_gateway

  def self.get_settings_for(method_name, key=nil, mode=nil)
    payment_gateway = PaymentGateway.find_by_method_name(method_name)
    instance_payment_gateway = self.where(payment_gateway_id: payment_gateway.id).first

    return self.settings_for_key(payment_gateway.settings, key) if instance_payment_gateway.nil?

    if mode.nil?
      settings = instance_payment_gateway.instance.test_mode? ? instance_payment_gateway.test_settings : instance_payment_gateway.live_settings
    else
      settings = instance_payment_gateway.send(:"#{mode}_settings")
    end

    settings_for_key(settings, key)
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
      settings
    else
      return String.new
    end
  end

  def self.find_or_build
    instance_payment_gateways = []
    PaymentGateway.all.each do | payment_gateway |
      instance_payment_gateway = self.where(payment_gateway_id: payment_gateway.id).first_or_initialize
      if instance_payment_gateway.id.nil?
        instance_payment_gateway.live_settings = payment_gateway.settings
        instance_payment_gateway.test_settings = payment_gateway.settings
        instance_payment_gateway.payment_gateway_id = payment_gateway.id
        instance_payment_gateways << instance_payment_gateway
      end
    end
    return instance_payment_gateways
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

end
