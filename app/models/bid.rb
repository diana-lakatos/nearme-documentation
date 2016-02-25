class Bid < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  has_custom_attributes target_type: 'ReservationType', target_id: :reservation_type_id

  belongs_to :offer, -> { with_deleted }
  belongs_to :user
  belongs_to :offer_creator, class_name: 'User'
  belongs_to :instance
  belongs_to :reservation_type
  has_many :payment_documents, as: :attachable, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  has_many :reviews, as: :reviewable

  accepts_nested_attributes_for :payment_documents, reject_if: -> (attributes) { attributes['file'].blank? && attributes['file_cache'].blank? }
  accepts_nested_attributes_for :user

  delegate :transactable_type_id, :transactable_type, :offer_type, to: :offer

  validates :user, :offer, presence: true

  scope :by_user, -> (user) { where(user: user) }
  scope :by_period, -> (start_date, end_date = Time.zone.today.end_of_day) {
    where(created_at: start_date..end_date)
  }

  state_machine :state, initial: :unconfirmed do
    event :confirm do
      transition unconfirmed: :accepted
    end

    event :reject do
      transition unconfirmed: :rejected
    end

    event :user_cancel do
      transition [:unconfirmed, :confirmed] => :cancelled_by_guest
    end

    event :expire do
      transition unconfirmed: :expired
    end

    after_transition unconfirmed: :accepted do |bid|
      bid.offer.finish_auction
    end
  end
end
