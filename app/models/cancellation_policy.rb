class CancellationPolicy < ActiveRecord::Base
  belongs_to :instance
  belongs_to :cancellable, polymorphic: true

  scope :refunds, -> { where(action_type: 'refund') }
  scope :penalties, -> { where(action_type: 'cancellation_penalty') }
  scope :allowed, -> { where(action_type: 'cancel_allowed') }

  AVAILABLE_ACTIONS = %w{cancel_allowed refund cancellation_penalty}

  validates :action_type, inclusion:  { in: AVAILABLE_ACTIONS }
  validates :condition, presence: true
  validates :amount_rule, presence: true, unless: Proc.new {|c| c.action_type == 'cancel_allowed'}

  def amount_cents
    return 0 unless conditions_met?
    Liquid::Template.parse(amount_rule, error_mode: :strict).render({'order' => cancellable}).strip.to_i
  end

  def conditions_met?
    Liquid::Template.parse(condition, error_mode: :strict).render({'order' => cancellable}).strip == 'true'
  end
end
