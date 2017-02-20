class PaypalAccount < ActiveRecord::Base
  include Encryptable
  include Modelable

  attr_accessor :payer
  attr_accessor :payment_method_nonce

  attr_encrypted :response

  belongs_to :instance_client, -> { with_deleted }
  belongs_to :instance
  belongs_to :payment_method, -> { with_deleted }
  has_one :payment_gateway, through: :payment_method
  has_many :payments, as: :payment_source

  validates :instance_client, presence: true

  delegate :customer_id, to: :instance_client
  delegate :plaid_configured?, to: :payment_method

  def name
    ''
  end

  def authorizable?
    express_payer_id.present? || payment_method_nonce.present?
  end

  def process!
    true
  end

  def to_active_merchant
    express_payer_id
  end

  def instance_client
    super || set_instance_client
  end

  def can_activate?
    false
  end

  def yaml_response
    YAML.load(response)
  end

  private

  def set_instance_client
    self.instance_client = payment_gateway.instance_clients.where(
      client: payer,
      test_mode: test_mode?
    ).first_or_initialize
  end

  def test_mode?
    self.test_mode ||= payment_gateway.test_mode?
  end

end
