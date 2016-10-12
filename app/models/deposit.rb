class Deposit < ActiveRecord::Base
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :target, polymorphic: true
  has_one :payment, as: :payable

  delegate :company, :user, :currency, :owner, :billing_authorization, to: :target
  delegate :authorize, :void!, to: :payment

  monetize :deposit_amount_cents, with_model_currency: :currency, allow_nil: true

  accepts_nested_attributes_for :payment

  before_create :set_authorized_at

  validates :payment, presence: true

  def build_payment(payment_attributes)
    super(
      payment_attributes.merge(
        company: company,
        currency: currency,
        subtotal_amount_cents: deposit_amount.cents,
        service_fee_amount_guest_cents:  0,
        service_fee_amount_host_cents:  0,
        service_additional_charges_cents: 0,
        host_additional_charges_cents:  0,
        payable: self
      )
    )
  end

  def set_authorized_at
    self.authorized_at = Time.now
  end
end
