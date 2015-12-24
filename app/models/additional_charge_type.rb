class AdditionalChargeType < ActiveRecord::Base
  attr_accessor :dummy

  STATUSES = ['mandatory', 'optional']
  COMMISSION_TYPES = ['mpo', 'host']

  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  monetize :amount_cents, with_model_currency: :currency

  # additional_charge_type_target polymorphic relation can join AdditionalChargeType with:
  # - Instance
  # - ProductType/ServiceType
  # - Product/Service
  belongs_to :additional_charge_type_target, polymorphic: true, touch: true
  has_many :additional_charges

  validates :name, :status, :amount, :currency, :commission_receiver, presence: true
  validates :amount, numericality: { less_than: 100000 }
  validates :status, inclusion: { in: STATUSES }
  validates :commission_receiver, inclusion: { in: COMMISSION_TYPES }

  scope :mandatory_charges, -> { where(status: 'mandatory') }
  scope :optional_charges, -> { where(status: 'optional') }
  scope :service, -> { where(commission_receiver: 'mpo') }
  scope :host, -> { where(commission_receiver: 'host') }
  scope :get_mandatory_and_optional_charges, -> (ids) { where("status = 'mandatory' or id in (?)", ids) }

  def mandatory?
    status == 'mandatory'
  end

  def optional?
    status == 'optional'
  end

  def additional_charge_type_targets
    TransactableType.all.map {|t| [t.name, t.signature] }.unshift(["Instance", current_instance.signature])
  end

  def additional_charge_type_target=(attribute)
    self.additional_charge_type_target_id, self.additional_charge_type_target_type = attribute.split(',')
  end

  private

  def current_instance
    @current_instance ||= PlatformContext.current.instance
  end
end
