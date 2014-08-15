class User < ActiveRecord::Base
  has_paper_trail :ignore => [:remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at,
                              :current_sign_in_ip, :last_sign_in_ip, :updated_at, :failed_attempts, :authentication_token,
                              :unlock_token, :locked_at, :google_analytics_id, :browser, :browser_version, :platform,
                              :bookings_count, :guest_rating_average, :guest_rating_count, :host_rating_average,
                              :host_rating_count, :avatar_versions_generated_at, :last_geolocated_location_longitude,
                              :last_geolocated_location_latitude, :instance_unread_messages_threads_count, :sso_log_out,
                              :avatar_transformation_data]
  acts_as_paranoid
  auto_set_platform_context

  extend FriendlyId
  has_metadata :accessors => [:support_metadata]
  friendly_id :name, use: [:slugged, :finders]

  has_many :authentications, :dependent => :destroy
  has_many :instance_clients, :as => :client, :dependent => :destroy
  has_many :company_users, -> { order(created_at: :asc) }, dependent: :destroy
  has_many :companies, :through => :company_users
  has_many :created_companies, :class_name => "Company", :foreign_key => 'creator_id', :inverse_of => :creator
  has_many :administered_locations, :class_name => "Location", :foreign_key => 'administrator_id', :inverse_of => :administrator
  has_many :administered_listings, :class_name => "Transactable", :through => :administered_locations, :source => :listings, :inverse_of => :administrator
  has_many :instance_admins, :foreign_key => 'user_id', :dependent => :destroy
  has_many :locations, :through => :companies, :inverse_of => :creator
  has_many :reservations, :foreign_key => 'owner_id'
  has_many :listings, :through => :locations, class_name: 'Transactable', :inverse_of => :creator
  has_many :photos, :foreign_key => 'creator_id', :inverse_of => :creator
  has_many :listing_reservations, :through => :listings, :source => :reservations, :inverse_of => :creator
  has_many :relationships, :class_name => "UserRelationship", :foreign_key => 'follower_id', :dependent => :destroy
  has_many :followed_users, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :class_name => "UserRelationship", :foreign_key => 'followed_id', :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :host_ratings, class_name: 'HostRating', foreign_key: 'subject_id'
  has_many :guest_ratings, class_name: 'GuestRating', foreign_key: 'subject_id'
  has_many :user_industries, :dependent => :destroy
  has_many :industries, :through => :user_industries
  has_many :mailer_unsubscriptions
  has_many :charges, foreign_key: 'user_id', dependent: :destroy
  has_many :authored_messages, :class_name => "UserMessage", :foreign_key => 'author_id', :inverse_of => :author
  has_many :tickets, -> { order 'updated_at DESC' }, :class_name => 'Support::Ticket'
  has_many :uploaded_confidential_files, foreign_key: 'uploader_id', dependent: :destroy, class_name: 'ConfidentialFile'
  has_many :confidential_files, as: :owner
  has_many :user_bans
  belongs_to :partner
  belongs_to :instance
  belongs_to :domain
  has_many :orders, foreign_key: :user_id, class_name: 'Spree::Order'

  before_save :ensure_authentication_token
  before_save :update_notified_mobile_number_flag
  before_validation :normalize_gender

  after_destroy :perform_cleanup
  before_restore :recover_companies

  store :required_fields

  accepts_nested_attributes_for :companies
  accepts_nested_attributes_for :confidential_files

  scope :patron_of, lambda { |listing|
    joins(:reservations).where(:reservations => { :transactable_id => listing.id }).uniq
  }

  scope :without, lambda { |users|
    users_ids = users.respond_to?(:pluck) ? users.pluck(:id) : Array.wrap(users).collect(&:id)
    users_ids.any? ? where('users.id NOT IN (?)', users_ids) : scoped
  }

  scope :ordered_by_email, -> { order('users.email ASC') }

  scope :visited_listing, ->(listing) {
    joins(:reservations).merge(Reservation.confirmed.past.for_listing(listing)).uniq
  }

  scope :hosts_of_listing, ->(listing) {
    where(:id => listing.try(:administrator_id)).uniq
  }

  scope :know_host_of, ->(listing) {
    joins(:followers).where(:user_relationships => {:follower_id => listing.administrator_id}).references(:user_relationships).uniq
  }

  scope :mutual_friends_of, ->(user) {
    joins(:followers).where(:user_relationships => {:follower_id => user.friends.pluck(:id)}).without(user).with_mutual_friendship_source
  }

  scope :with_mutual_friendship_source, -> {
    joins(:followers).select('"users".*, "user_relationships"."follower_id" AS mutual_friendship_source')
  }

  scope :for_instance, ->(instance) {
    instance.is_desksnearme? ? where('users.instance_id IS NULL OR users.instance_id = ?', instance.id) : where(:'users.instance_id' => instance.id)
  }

  extend CarrierWave::SourceProcessing
  mount_uploader :avatar, AvatarUploader, :use_inkfilepicker => true
  skip_callback :commit, :after, :remove_avatar!

  BIOGRAPHY_MAX_LENGTH = 2000

  validates_presence_of :name
  validates_presence_of :first_name

  # FIXME: This is an unideal coupling of 'required parameters' for specific forms
  #        to the general validations on the User model.
  #        A solution moving forward is to extract the relevant forms into
  #        a 'Form' object containing their own additional validations specific
  #        to their context.
  validates_presence_of :phone, :if => :phone_required
  validates_presence_of :country_name, :if => lambda { phone_required || country_name_required }

  validates :current_location, length: {maximum: 50}
  validates :company_name, length: {maximum: 50}
  validates :job_title, length: {maximum: 50}
  validates :skills_and_interests, length: {maximum: 150}
  validates :biography, length: {maximum: BIOGRAPHY_MAX_LENGTH}

  attr_accessor :skip_custom_validation

  validate do |user|
    if user.persisted? && PlatformContext.current.instance.user_info_in_onboarding_flow? && !self.skip_custom_validation
      PlatformContext.current.instance.user_required_fields.each do |field|
        field_to_check = field == 'avatar' ? 'avatar_original_url' : field
        user.errors.add(field, I18n.t('errors.messages.blank')) unless self.send(field_to_check).present?
      end
    end
  end

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :user_validatable, :token_authenticatable, :temporary_token_authenticatable

  attr_accessor :phone_required, :country_name_required, :skip_password, :verify_identity

  # attr_accessible :name, :email, :phone, :job_title, :password, :avatar, :avatar_versions_generated_at, :avatar_transformation_data,
  #   :biography, :industry_ids, :country_name, :mobile_number, :facebook_url, :twitter_url, :linkedin_url, :instagram_url,
  #   :current_location, :company_name, :skills_and_interests, :last_geolocated_location_longitude, :last_geolocated_location_latitude,
  #
  #   :domain_id, :time_zone, :companies_attributes, :sms_notifications_enabled, :sms_preferences

  serialize :sms_preferences, Hash
  serialize :instance_unread_messages_threads_count, Hash
  serialize :avatar_transformation_data, Hash

  delegate :to_s, :to => :name

  SMS_PREFERENCES = %w(user_message reservation_state_changed new_reservation)

  # Build a new user, taking into account session information such as Provider
  # authentication.
  def self.new_with_session(attrs, session)
    user = super
    user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    user
  end

  # FIND undeleted users first (for example for find_by_email finds)
  def self.with_deleted
    super.order('deleted_at IS NOT NULL, deleted_at DESC')
  end

  def apply_omniauth(omniauth)
    self.name = omniauth['info']['name'] if name.blank?
    self.email = omniauth['info']['email'] if email.blank?
    expires_at = omniauth['credentials'] && omniauth['credentials']['expires_at'] ? Time.at(omniauth['credentials']['expires_at']) : nil
    token = omniauth['credentials'] && omniauth['credentials']['token']
    secret = omniauth['credentials'] && omniauth['credentials']['secret']
    authentications.build(:provider => omniauth['provider'],
                          :uid => omniauth['uid'],
                          :info => omniauth['info'],
                          :token => token,
                          :secret => secret,
                          :token_expires_at => expires_at)
  end

  def cancelled_reservations
    reservations.cancelled
  end

  def rejected_reservations
    reservations.rejected
  end

  def expired_reservations
    reservations.expired
  end

  def confirmed_reservations
    reservations.confirmed
  end

  def name(avoid_stack_too_deep = nil)
    avoid_stack_too_deep = false if avoid_stack_too_deep.nil?
    name_from_components(avoid_stack_too_deep).presence || self.read_attribute(:name).to_s.split.collect{|w| w[0] = w[0].capitalize; w}.join(' ')
  end

  def name_from_components(avoid_stack_too_deep)
    return '' if avoid_stack_too_deep
    [first_name, middle_name, last_name].select { |s| s.present? }.join(' ')
  end

  def first_name
    (self.read_attribute(:first_name)) || (name(true).split[0...1].join(' '))
  end

  def middle_name
    (self.read_attribute(:middle_name)) || (name(true).split.length > 2 ? name(true).split[1] : '')
  end

  def last_name
    (self.read_attribute(:last_name)) || (name(true).split.length > 1 ? name(true).split.last : '')
  end

  # Whether to validate the presence of a password
  def password_required?
    # we want to enforce skipping password for instance_admin/users#create
    return false if self.skip_password == true
    return true if self.skip_password == false
    # We're changing/setting password, or new user and there are no Provider authentications
    !password.blank? || (new_record? && authentications.empty?)
  end

  # Whether the user has - or should have - a password.
  def has_password?
    encrypted_password.present? || password_required?
  end

  # Don't require current_password in order to update from Devise.
  def update_with_password(attrs)
    update_attributes(attrs)
  end

  def generate_random_password!
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    random_pass = ''
    1.upto(8) { |i| random_pass << chars[rand(chars.size-1)] }
    self.password = random_pass
  end

  def linked_to?(provider)
    authentications.where(provider: provider).any?
  end

  def has_phone_and_country?
    country_name.present? && phone.present?
  end

  def phone_or_country_was_changed?
    (phone_changed? && phone_was.blank?) || (country_name_changed? && country_name_was.blank?)
  end

  def full_mobile_number_updated?
    mobile_number_changed? || country_name_changed?
  end

  def update_notified_mobile_number_flag
    self.notified_about_mobile_number_issue_at = nil if full_mobile_number_updated?
    # necessary hack, http://apidock.com/rails/ActiveRecord/RecordNotSaved
    nil
  end

  def notify_about_wrong_phone_number
    unless notified_about_mobile_number_issue_at
      UserMailer.notify_about_wrong_phone_number(self).deliver
      update_attribute(:notified_about_mobile_number_issue_at, Time.zone.now)
      IssueLogger.log_issue("[internal] invalid mobile number", email, "#{name} (#{id}) was asked to update his mobile number #{full_mobile_number}")
    end
  end

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user, auth = nil)
    relationships.create!(followed_id: other_user.id, authentication_id: auth.try(:id))
  end

  def add_friend(users, auth = nil)
    raise ArgumentError, "Invalid Authentication for User ##{self.id}" if auth && auth.user != self
    Array.wrap(users).each do |user|
      next if self.friends.exists?(user)
      friend_auth = auth.nil? ? nil : user.authentications.where(provider: auth.provider).first
      user.follow!(self, friend_auth)
      self.follow!(user, auth)
    end
  end
  alias_method :add_friends, :add_friend

  def friends
    self.followed_users.without(self)
  end

  def friends_know_host_of(listing)
    # TODO Rails 4 - merge
    self.friends && User.know_host_of(listing)
  end

  def social_connections
    self.authentications
  end

  def mutual_friendship_source
    self.class.find_by_id(self[:mutual_friendship_source].to_i) if self[:mutual_friendship_source]
  end

  def mutual_friends
    self.class.without(self).mutual_friends_of(self)
  end

  def full_email
    "#{name} <#{email}>"
  end

  def country
    Country.find(country_name) if country_name.present?
  end

  # Returns the mobile number with the full international calling prefix
  def full_mobile_number
    return unless mobile_number.present?

    number = mobile_number
    number = "+#{country.calling_code}#{number.gsub(/^0/, "")}" if country.try(:calling_code)
    number
  end

  def accepts_sms?
    full_mobile_number.present? && sms_notifications_enabled?
  end

  def accepts_sms_with_type?(sms_type)
    accepts_sms? && sms_preferences[sms_type.to_s].present?
  end

  def avatar_changed?
    false
  end

  def default_company
    self.companies.first
  end

  def first_listing
    if companies.first and companies.first.locations.first
      companies.first.locations.first.listings.first
    end
  end

  def has_listing_without_price?
    listings.any?(&:free?)
  end

  def log_out!
    self.update_attribute(:sso_log_out, true)
  end

  def logged_out!
    self.update_attribute(:sso_log_out, false)
  end

  def email_verification_token
    Digest::SHA1.hexdigest(
      "--dnm-token-#{self.id}-#{self.created_at}"
    )
  end

  def generate_payment_token
    new_token = SecureRandom.hex(32)
    self.update_attribute(:payment_token, new_token)
    new_token
  end

  def verify_payment_token(token)
    return false if self.payment_token.nil?
    current_token = self.payment_token
    self.update_attribute(:payment_token, nil)
    current_token == token
  end

  def verify_email_with_token(token)
    if token.present? && self.email_verification_token == token && !self.verified_at
      self.verified_at = Time.zone.now
      self.save(:validate => false)
      true
    else
      false
    end
  end

  def to_liquid
    UserDrop.new(self)
  end

  def to_param
    caller[0].include?('friendly_id') ? super : id
  end

  def to_balanced_params
    {
      name: name,
      email: email,
      phone: phone
    }
  end

  def is_location_administrator?
    administered_locations.size > 0
  end

  def user_messages
    UserMessage.for_user(self)
  end

  def unread_user_message_threads_count_for(instance)
    self.instance_unread_messages_threads_count.fetch(instance.id, 0)
  end

  def listings_in_near(results_size = 3, radius_in_km = 100, without_listings_from_cancelled_reservations = false)
    return [] if PlatformContext.current.nil?
    locations_in_near = nil
    # we want allow greenwhich and friends, but probably 0 latitude and 0 longitude is not valid location :)
    if last_geolocated_location_latitude.nil? || last_geolocated_location_longitude.nil? || (last_geolocated_location_latitude.to_f.zero? && last_geolocated_location_longitude.to_f.zero?)
      locations_in_near = Location.includes(:location_address).near(current_location, radius_in_km, units: :km) # TODO, order: :distance)
    else
      locations_in_near = Location.includes(:location_address).near([last_geolocated_location_latitude, last_geolocated_location_longitude], radius_in_km, units: :km) # TODO , order: :distance)
    end

    listing_ids_of_cancelled_reservations = self.reservations.cancelled_or_expired_or_rejected.pluck(:transactable_id) if without_listings_from_cancelled_reservations

    listings = []
    locations_in_near.includes(:listings).each do |location|
      if without_listings_from_cancelled_reservations and !listing_ids_of_cancelled_reservations.empty?
        listings += location.listings.searchable.where('transactables.id NOT IN (?)', listing_ids_of_cancelled_reservations).limit((listings.size - results_size).abs)
      else
        listings += location.listings.searchable.limit((listings.size - results_size).abs)
      end
      return listings if listings.size >= results_size
    end if locations_in_near
    listings.uniq
  end

  def can_manage_listing?(listing)
    listing.company && listing.company.company_users.where(user_id: self.id).any?
  end

  def administered_locations_pageviews_30_day_total
    scoped_locations = (!companies.count.zero? && self == self.companies.first.creator) ? self.companies.first.locations : administered_locations
    scoped_locations = scoped_locations.with_searchable_listings
    Impression.where('impressionable_type = ? AND impressionable_id IN (?) AND DATE(impressions.created_at) >= ?', 'Location', scoped_locations.pluck(:id), Date.current - 30.days).count
  end

  def unsubscribe(mailer_name)
    mailer_unsubscriptions.create(mailer: mailer_name)
  end

  def unsubscribed?(mailer_name)
    mailer_unsubscriptions.where(mailer: mailer_name).any?
  end

  def perform_cleanup
    # we invoke cleanup from user_ban as well. in afrer_destroy this user is not included, but in user_ban it is included
    cleanup(0)
  end

  def cleanup(company_users_number = 1)
    self.created_companies.each do |company|
      if company.company_users.count == company_users_number
        company.destroy
      else
        company.creator = company.company_users.find { |cu| cu.user_id != self.id }.user
        company.save!
      end
    end
    self.administered_locations.each do |location|
      location.update_attribute(:administrator_id, nil) if location.administrator_id == self.id
    end
    self.reservations.unconfirmed.find_each do |r|
      r.user_cancel!
    end
  end

  def recover_companies
    self.created_companies.only_deleted.where('deleted_at >= ? AND deleted_at <= ?',  self.deleted_at, self.deleted_at + 30.seconds).each do |company|
      begin
        company.restore(:recursive => true)
      rescue
      end
    end

  end

  # Returns a temporary token to be used as the login token parameter
  # in URLs to automatically log the user in.
  def temporary_token(expires_at = 48.hours.from_now)
    User::TemporaryTokenVerifier.new(self).generate(expires_at)
  end

  def facebook_url
    social_url('facebook')
  end

  def twitter_url
    social_url('twitter')
  end

  def linkedin_url
    social_url('linkedin')
  end

  def instagram_url
    social_url('instagram')
  end

  def social_url(provider)
    authentications.where(provider: provider).
      where('profile_url IS NOT NULL').
      order('created_at asc').last.try(:profile_url)
  end

  def is_trusted?
    PlatformContext.current.instance.onboarding_verification_required ? (self.confidential_files.accepted.count > 0) : true
  end

  def confidential_file_acceptance_cancelled!
    listings.find_each(&:confidential_file_acceptance_cancelled!)
  end

  def confidential_file_accepted!
    listings.find_each(&:confidential_file_accepted!)
  end

  def active_for_authentication?
    super && !banned?
  end

  def banned?
    user_bans.count > 0
  end

  def self.xml_attributes
    self.csv_fields.keys
  end

  def self.csv_fields
    {email: 'User Email', name: 'User Name'}
  end

  def normalize_gender
    return if self.gender.nil?
    self.gender.downcase!
    unless ['male', 'female', 'unknown'].include?(gender)
      self.gender = nil
    end
  end

  def has_draft_listings
    get_instance_metadata("has_draft_listings")
  end

  def has_any_active_listings
    get_instance_metadata("has_any_active_listings")
  end

  def companies_metadata
    get_instance_metadata("companies_metadata")
  end

  def instance_admins_metadata
    get_instance_metadata("instance_admins_metadata")
  end

end
