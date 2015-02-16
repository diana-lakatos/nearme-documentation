class AdditionalChargeType < ActiveRecord::Base
  has_paper_trail
  auto_set_platform_context
  scoped_to_platform_context
  monetize :amount_cents, with_model_currency: :currency

  belongs_to :instance
  has_many :additional_charges

  validates :name, :status, :amount, :currency, :commission_for, presence: true
  validate :correct_status, :commission_recipient

  scope :mandatory_charges, -> { where(status: 'mandatory') }
  scope :optional_charges, -> { where(status: 'optional') }
  scope :get_charges, -> (ids) { where("status = 'mandatory' or id in (?)", ids) }

  STATUSES = ['mandatory', 'optional']
  COMMISSION_TYPES = ['mpo']

  def mandatory?
    status == 'mandatory'
  end

  def optional?
    status == 'optional'
  end

  # This is a stub since for now we do not connect AC with the different services in the marketplace
  def service
    'All (Services and Buy/Sell)'
  end

  private
  def correct_status
    unless status && STATUSES.include?(status.upcase.downcase!)
      errors.add(:status, ' can only be mandatory or optional')
    end
  end

  def commission_recipient
    unless commission_for && COMMISSION_TYPES.include?(commission_for.upcase.downcase!)
      errors.add(:commission_for, ' recipient can only be MPO')
    end
  end
end
