# frozen_string_literal: true
class ChargeType < ActiveRecord::Base
  attr_accessor :dummy

  STATUSES = %w(mandatory optional).freeze
  COMMISSION_TYPES = %w(mpo host).freeze
  CHARGE_EVENT = { order_confirm: I18n.t('charge_type.charge_at.confirm') }.freeze

  include Modelable

  monetize :amount_cents, with_model_currency: :currency, allow_nil: true

  belongs_to :charge_type_target, polymorphic: true, touch: true

  validates :name, :status, :commission_receiver, presence: true
  validates :amount, presence: true, numericality: { less_than: 100_000 }, if: proc { |a| a.percent.to_i.zero? }
  validates :amount, absence: true, if: proc { |a| !a.percent.to_i.zero? }
  validates :percent, presence: true, numericality: { less_than: 100_000 }, if: proc { |a| a.amount.to_i.zero? && !a.percent.to_i.zero? }
  validates :status, inclusion: { in: STATUSES }
  validates :commission_receiver, inclusion: { in: COMMISSION_TYPES }
  validate :charge_type_target_presence

  scope :admin_charges, lambda {
    where(charge_type_target_type: %w(TransactableType Instance))
  }
  scope :mandatory_charges, -> { where(status: 'mandatory') }
  scope :optional_charges, -> { where(status: 'optional') }
  scope :service, -> { where(commission_receiver: 'mpo') }
  scope :host, -> { where(commission_receiver: 'host') }
  scope :get_mandatory_and_optional_charges, ->(ids) { where("status = 'mandatory' or id in (?)", ids) }

  after_save :clear_transactable_cache
  after_destroy :clear_transactable_cache

  def mandatory?
    status == 'mandatory'
  end

  def optional?
    status == 'optional'
  end

  def count_charge_amount(base_amount)
    amount.presence || (percent * base_amount) / 100
  end

  private

  def charge_type_target_presence
    # errors.add(:charge_type_target) if charge_type_target_type.blank?
  end

  def clear_transactable_cache
    if charge_type_target.instance_of?(Instance)
      charge_type_target.fast_recalculate_cache_key!
    elsif charge_type_target.respond_to?(:instance)
      charge_type_target.instance.fast_recalculate_cache_key!
    end
  end
end
