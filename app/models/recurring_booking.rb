class RecurringBooking < ActiveRecord::Base
  class NotFound < ActiveRecord::RecordNotFound; end
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  inherits_columns_from_association([:company_id, :administrator_id, :creator_id], :listing)
  serialize :schedule_params, Hash

  before_create :store_platform_context_detail

  attr_encrypted :authorization_token, :payment_gateway_class, :key => DesksnearMe::Application.config.secret_token

  belongs_to :instance
  belongs_to :listing, class_name: 'Transactable', foreign_key: 'transactable_id', inverse_of: :recurring_bookings
  delegate :location, to: :listing
  belongs_to :owner, :class_name => "User"
  belongs_to :creator, class_name: "User"
  belongs_to :administrator, class_name: "User"
  belongs_to :company
  belongs_to :platform_context_detail, :polymorphic => true

  has_many :reservations, dependent: :destroy
  validates :transactable_id, :presence => true
  validates :owner_id, :presence => true, :unless => lambda { owner.present? }
  validate :at_least_one_valid_reservation

  scope :upcoming, lambda { where('end_on > ?', Time.zone.now) }
  scope :not_archived, lambda { upcoming.without_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired).uniq }
  scope :visible, lambda { without_state(:cancelled_by_guest, :cancelled_by_host).upcoming }
  scope :not_rejected_or_cancelled, lambda { without_state(:cancelled_by_guest, :cancelled_by_host, :rejected) }
  scope :cancelled, lambda { with_state(:cancelled_by_guest, :cancelled_by_host) }
  scope :confirmed, lambda { with_state(:confirmed) }
  scope :rejected, lambda { with_state(:rejected) }
  scope :expired, lambda { with_state(:expired) }
  scope :cancelled_or_expired_or_rejected, lambda { with_state(:cancelled_by_guest, :cancelled_by_host, :rejected, :expired) }
  scope :archived, lambda { where('end_on < ? OR state IN (?)', Time.zone.today, ['rejected', 'expired', 'cancelled_by_host', 'cancelled_by_guest']).uniq }

  state_machine :state, initial: :unconfirmed do
    after_transition unconfirmed: :confirmed, do: :confirm_remaining
    after_transition [:unconfirmed, :confirmed] => :cancelled_by_guest, do: :cancel_by_guest_remaining
    after_transition confirmed: :cancelled_by_host, do: :cancel_by_host_remaining
    after_transition unconfirmed: :rejected, do: :reject_remaining
    after_transition unconfirmed: :expired, do: :expire_remaining

    event :confirm do
      transition unconfirmed: :confirmed
    end

    event :reject do
      transition unconfirmed: :rejected
    end

    event :host_cancel do
      transition confirmed: :cancelled_by_host
    end

    event :user_cancel do
      transition [:unconfirmed, :confirmed] => :cancelled_by_guest
    end

    event :expire do
      transition unconfirmed: :expired
    end
  end

  def store_platform_context_detail
    self.platform_context_detail_type = PlatformContext.current.platform_context_detail.class.to_s
    self.platform_context_detail_id = PlatformContext.current.platform_context_detail.id
  end

  def administrator
    super.presence || creator
  end

  def credit_card_payment?
    payment_method == Reservation::PAYMENT_METHODS[:credit_card]
  end

  def schedule_params=(params)
    write_attribute(:schedule_params, RecurringSelect.dirty_hash_to_rule(params).to_hash)
  end

  def schedule(schedule_start = nil)
    options ||= {}
    schedule_start ||= start_on + start_minute.to_f.minutes
    options[:duration] = (end_minute - start_minute)*60 if end_minute && start_minute
    IceCube::Schedule.new(schedule_start, options).tap do |s|
      s.add_recurrence_rule(RecurringSelect.dirty_hash_to_rule(self.schedule_params))
    end
  end

  def at_least_one_valid_reservation
    if reservations.any?(&:valid?)
      true
    else
      errors.add(:reservations, I18n.t("activerecord.errors.models.recurring_booking.one_valid_reservation"))
      false
    end
  end

  def host
    @host ||= creator
  end

  def my_booking_status_info
    if state == 'unconfirmed'
      tooltip_text = "Pending confirmation from host. Booking will expire in #{time_to_expiry(expiry_time)}."
      link_text = "<span class='tooltip-spacer'>i</span>".html_safe

      tooltip(tooltip_text, link_text, {class: status_icon}, nil)
    else
      "<i class='#{status_icon}'></i>".html_safe
    end
  end

  def expiry_time
    created_at + 24.hours
  end

  def time_to_expiry(time_of_event)
    current_time = Time.zone.now
    total_seconds = time_of_event - current_time
    hours = (total_seconds/1.hour).floor
    minutes = ((total_seconds-hours.hours)/1.minute).floor
    if hours < 1 and minutes < 1
      'less than minute'
    else
      if hours < 1
        '%d minutes' % [minutes]
      else
        '%d hours, %d minutes' % [hours, minutes]
      end
    end
  end

  def schedule_expiry
    RecurringBookingExpiryJob.perform_later(expiry_time, self.id)
  end

  def perform_expiry!
    if unconfirmed? && !deleted?
      expire!

      # FIXME: This should be moved to a background job base class, as per ApplicationController.
      #        The event_tracker calls can be executed from the Job instance.
      #        i.e. Essentially compose this as a 'non-http request' controller.
      mixpanel_wrapper = AnalyticWrapper::MixpanelApi.new(AnalyticWrapper::MixpanelApi.mixpanel_instance, :current_user => owner)
      event_tracker = Analytics::EventTracker.new(mixpanel_wrapper, AnalyticWrapper::GoogleAnalyticsApi.new(owner))
      event_tracker.recurring_booking_expired(self)
      event_tracker.updated_profile_information(self.owner)
      event_tracker.updated_profile_information(self.host)

      RecurringBookingMailer.notify_guest_of_expiration(self).deliver
      RecurringBookingMailer.notify_host_of_expiration(self).deliver
    end
  end

  def archived?
    rejected? or cancelled? or end_on < Time.zone.today
  end

  def cancelled?
    cancelled_by_host? || cancelled_by_guest?
  end

  def confirm_remaining
    reservations.unconfirmed.each(&:confirm!)
  end

  def cancel_by_host_remaining
    reservations.confirmed.each do |r|
      r.host_cancel! if r.cancelable?
    end
  end

  def cancel_by_guest_remaining
    reservations.confirmed_or_unconfirmed.each do |r|
      r.user_cancel! if r.cancelable?
    end
  end

  def reject_remaining
    reservations.unconfirmed.each(&:reject!)
  end

  def expire_remaining
    reservations.unconfirmed.each(&:expire!)
  end

  def hourly_reservations?
    start_minute.present? && end_minute.present?
  end

  def hours
    if start_minute && end_minute
      (end_minute - start_minute) / 60.0
    else
      0
    end
  end

end

