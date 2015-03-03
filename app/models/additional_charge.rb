class AdditionalCharge < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context

  after_initialize :copy_ac_type_data, if: :new_record?

  belongs_to :instance
  belongs_to :additional_charge_type
  belongs_to :target, polymorphic: true

  validates :additional_charge_type_id, presence: true

  monetize :amount_cents, with_model_currency: :currency

  def mandatory?
    status == 'mandatory'
  end

  def optional?
    status == 'optional'
  end

  private
  # We need to copy this data from AdditionalChargeType record
  # to have accurate information about the charge
  # since information in AdditionalChargeType can change with time
  def copy_ac_type_data
    return if additional_charge_type_id.blank?
    self.name = additional_charge_type.name
    self.amount_cents = additional_charge_type.amount_cents
    self.commission_receiver = additional_charge_type.commission_receiver
    self.status = additional_charge_type.status
  end
end
