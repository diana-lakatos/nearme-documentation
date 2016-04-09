class AdditionalCharge < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  attr_accessor :selected

  after_initialize :copy_ac_type_data, if: :new_record?

  belongs_to :instance, touch: true
  belongs_to :additional_charge_type

  before_destroy :check_if_mandatory

  # Target is Spree::Order or Reservation
  belongs_to :target, polymorphic: true

  monetize :amount_cents, with_model_currency: :currency

  scope :mandatory, -> { where(status: 'mandatory') }
  scope :optional, -> { where(status: 'optional') }
  scope :host, -> { where(commission_receiver: 'host') }
  scope :service, -> { where(commission_receiver: 'mpo') }

  def mandatory?
    status == 'mandatory'
  end

  def optional?
    status == 'optional'
  end

  def to_liquid
    @additional_charge_drop ||= AdditionalChargeDrop.new(self)
  end

  private
  # We need to copy this data from AdditionalChargeType record
  # to have accurate information about the charge
  # since information in AdditionalChargeType can change with time
  def copy_ac_type_data
    return if additional_charge_type_id.blank?
    self.name = additional_charge_type.name

    #amount in additional_charge_type is in USD. If we try to copy amount_cents, it already includes conversion to cents in 100 to 1 ratio.
    # If additional charge is in different currency, we need to make sure that we make proper conversion from 100 to 1 ratio into currency's ratio.
    # MGA for example uses 5 to 1 ratio, so if amount to copy is 25, we transform it into 2500. We then divide this by 100 / 5 -> 2500 / 20 -> 125.
    # It is then correct amount, because 125 / 5 gives us again initial 25 full 'dollar' amount. Test coverage in test/integrations/commissions<tab>
    if additional_charge_type.percent.to_i.zero?
      self.amount_cents = additional_charge_type.amount_cents / (100 / Money::Currency.new(currency.presence || PlatformContext.current.instance.default_currency).subunit_to_unit.to_f)
    else
      self.amount_cents = target.subtotal_amount_cents * additional_charge_type.percent.to_i / 100 / (100 / Money::Currency.new(currency.presence || PlatformContext.current.instance.default_currency).subunit_to_unit.to_f)
    end

    self.commission_receiver = additional_charge_type.commission_receiver
    self.status = additional_charge_type.status
  end

  def check_if_mandatory
    false if mandatory?
  end
end
