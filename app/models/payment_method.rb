class PaymentMethod < ActiveRecord::Base

  PAYMENT_METHOD_TYPES = %w{credit_card nonce express_checkout manual remote free}.freeze

  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  scope :active, -> { where(active: true) }
  scope :manual, -> { where(payment_method_type: 'manual') }
  scope :credit_card, -> { where(payment_method_type: 'credit_card') }
  scope :remote, -> { where(payment_method_type: 'remote') }
  scope :free, -> { where(payment_method_type: 'free') }
  scope :except_free, -> { where.not(payment_method_type: 'free') }

  belongs_to :payment_gateway, -> { with_deleted }

  has_many :orders
  has_many :payments

  validates :payment_method_type, presence: true, inclusion: { in: PAYMENT_METHOD_TYPES }

  PAYMENT_METHOD_TYPES.each do |pmt|
    define_method("#{pmt}?") { self.payment_method_type == pmt.to_s }
  end

  def name
    self.class.human_attribute_name("payment_method_type." + self.payment_method_type.to_s)
  end

  def capturable?
    [:credit_card, :nonce, :express_checkout, :remote].include?(self.payment_method_type.to_sym)
  end

end
