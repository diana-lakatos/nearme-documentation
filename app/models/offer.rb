class Offer < ActiveRecord::Base
  include Categorizable
  include Approvable
  extend FriendlyId

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_custom_attributes target_type: 'OfferType', target_id: :transactable_type_id
  friendly_id :slug_candidates, use: [:slugged, :finders, :scoped], scope: :instance

  belongs_to :instance
  belongs_to :company
  belongs_to :creator, class_name: 'User'
  belongs_to :offer_type, -> { with_deleted }, foreign_key: :transactable_type_id
  belongs_to :transactable_type, -> { with_deleted }
  has_many :bids
  has_many :photos, as: :owner, dependent: :destroy do
    def thumb
      (first || build).thumb
    end
  end
  has_many :attachments, -> { order(:id) }, class_name: 'SellerAttachment', as: :assetable
  has_many :document_requirements, as: :item, dependent: :destroy, inverse_of: :item
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_one :upload_obligation, as: :item, dependent: :destroy

  accepts_nested_attributes_for :document_requirements, allow_destroy: true, reject_if: :document_requirement_hidden?
  accepts_nested_attributes_for :upload_obligation
  accepts_nested_attributes_for :photos
  accepts_nested_attributes_for :approval_requests

  validates :name, presence: true

  monetize :price_cents, with_model_currency: :currency, allow_nil: true

  scope :active, -> { where(draft_at: nil) }
  scope :draft, -> { where.not(draft_at: nil) }
  scope :with_date, ->(date) { where(created_at: date) }
  scope :for_transactable_type_id, -> (transactable_type_id) { where(transactable_type_id: transactable_type_id) }

  state_machine :state, initial: :auction_open do
    event :finish_auction do
      transition auction_open: :auction_finished
    end

    event :cancel_auction do
      transition auction_open: :auction_cancelled
    end

    event :resolve_case do
      transition auction_open: :case_resolved
    end

    after_transition auction_open: [:auction_finished, :auction_cancelled] do |offer|
      offer.bids.without_state(:accepted).map(&:reject)
    end

  end

  def create_a_bid(current_user)
    self.bids.create(user: current_user)
  end

  def to_liquid
    @offer_drop ||= OfferDrop.new(self)
  end

  def slug_candidates
    [
      :name,
      [:name, self.class.last.try(:id).to_i + 1],
      [:name, rand(1000000)]
    ]
  end

  def document_requirement_hidden?(attributes)
    attributes.merge!(_destroy: '1') if attributes['removed'] == '1'
    attributes['hidden'] == '1'
  end

  def currency
    read_attribute(:currency).presence || offer_type.try(:default_currency)
  end

  def reviews
    @reviews ||= Review.for_reviewables(self.bids.pluck(:id), 'Bid')
  end

  def recalculate_average_rating!
    average_rating = reviews.average(:rating) || 0.0
    self.update(average_rating: average_rating)
  end

  class NotFound < ActiveRecord::RecordNotFound; end

end
