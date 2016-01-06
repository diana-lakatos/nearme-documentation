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
  validate :additional_charge_type_target_presence

  scope :admin_charges, -> {
    where(additional_charge_type_target_type: ['ServiceType', 'Spree::ProductType', 'Instance'])
  }
  scope :mandatory_charges, -> { where(status: 'mandatory') }
  scope :optional_charges, -> { where(status: 'optional') }
  scope :service, -> { where(commission_receiver: 'mpo') }
  scope :host, -> { where(commission_receiver: 'host') }
  scope :get_mandatory_and_optional_charges, -> (ids) { where("status = 'mandatory' or id in (?)", ids) }

  after_save :clear_transactable_cache
  after_destroy :clear_transactable_cache

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

  def additional_charge_type_target_presence
    errors.add(:additional_charge_type_target) if additional_charge_type_target_type.blank?
  end

  def current_instance
    @current_instance ||= PlatformContext.current.instance
  end

  def clear_transactable_cache
    if additional_charge_type_target.instance_of?(Instance)
      additional_charge_type_target.fast_recalculate_cache_key!
    elsif additional_charge_type_target.respond_to?(:instance)
      additional_charge_type_target.instance.fast_recalculate_cache_key!
    end
  end
end
