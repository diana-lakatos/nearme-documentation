class User < ActiveRecord::Base
  geocoded_by :current_location, :latitude  => :last_geolocated_location_latitude, :longitude => :last_geolocated_location_longitude

  include Spree::UserPaymentSource

  SORT_OPTIONS = ['All', 'Featured', 'People I know', 'Most Popular', 'Distance', 'Number of Projects']

  has_paper_trail ignore: [:remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at,
                           :current_sign_in_ip, :last_sign_in_ip, :updated_at, :failed_attempts, :authentication_token,
                           :unlock_token, :locked_at, :google_analytics_id, :browser, :browser_version, :platform,
                           :avatar_versions_generated_at, :last_geolocated_location_longitude,
                           :last_geolocated_location_latitude, :instance_unread_messages_threads_count, :sso_log_out,
                           :avatar_transformation_data, :metadata]
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context allow_admin: :admin
  acts_as_tagger

  extend FriendlyId
  has_metadata accessors: [:support_metadata]
  friendly_id :name, use: [:slugged, :finders]

  attr_readonly :following_count
  attr_readonly :followers_count

  belongs_to :billing_address, class_name: 'Spree::Address'
  belongs_to :domain
  belongs_to :instance
  belongs_to :instance_profile_type, -> { with_deleted }
  belongs_to :partner
  belongs_to :spree_shipping_address, class_name: 'Spree::Address', foreign_key: 'shipping_address_id'
  has_many :shipping_addresses
  has_many :activity_feed_events, as: :event_source, dependent: :destroy
  has_many :activity_feed_subscriptions, foreign_key: 'follower_id'
  has_many :activity_feed_subscriptions_as_followed, as: :followed, class_name: 'ActivityFeedSubscription', dependent: :destroy
  has_many :administered_locations, class_name: "Location", foreign_key: 'administrator_id', inverse_of: :administrator
  has_many :administered_listings, class_name: "Transactable", through: :administered_locations, source: :listings, inverse_of: :administrator
  has_many :authentications, dependent: :destroy
  has_many :assigned_tickets, -> { order 'updated_at DESC' }, foreign_key: 'assigned_to_id', class_name: 'Support::Ticket'
  has_many :assigned_company_tickets, -> { where(target_type: ['Transactable', 'Spree::Product']).order('updated_at DESC') }, foreign_key: 'assigned_to_id', class_name: 'Support::Ticket'
  has_many :approval_request_attachments, foreign_key: 'uploader_id'
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :authored_messages, class_name: "UserMessage", foreign_key: 'author_id', inverse_of: :author
  has_many :blog_posts, class_name: 'UserBlogPost'
  has_many :categories_categorizable, as: :categorizable
  has_many :categories, through: :categories_categorizable
  has_many :charges, foreign_key: 'user_id', dependent: :destroy
  has_many :company_users, -> { order(created_at: :asc) }, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :comments, inverse_of: :creator
  has_many :created_companies, class_name: "Company", foreign_key: 'creator_id', inverse_of: :creator
  has_many :feed_followers, through: :activity_feed_subscriptions_as_followed, source: :follower
  has_many :feed_followed_projects, through: :activity_feed_subscriptions, source: :followed, source_type: 'Project'
  has_many :feed_followed_topics, through: :activity_feed_subscriptions, source: :followed, source_type: 'Topic'
  has_many :feed_followed_users, through: :activity_feed_subscriptions,  source: :followed, source_type: 'User'
  has_many :feed_following, through: :activity_feed_subscriptions, source: :follower
  has_many :followed_users, through: :relationships, source: :followed
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :instance_clients, as: :client, dependent: :destroy
  has_many :industries, through: :user_industries
  has_many :instance_admins, foreign_key: 'user_id', dependent: :destroy
  has_many :listings, through: :locations, class_name: 'Transactable', inverse_of: :creator
  has_many :listing_reservations, class_name: 'Reservation', through: :listings, source: :reservations, inverse_of: :creator
  has_many :listing_recurring_bookings, class_name: 'RecurringBooking', through: :listings, source: :recurring_bookings, inverse_of: :creator
  has_many :locations, through: :companies, inverse_of: :creator
  has_many :mailer_unsubscriptions
  has_many :orders, foreign_key: :user_id, class_name: 'Spree::Order'
  has_many :photos, foreign_key: 'creator_id', inverse_of: :creator
  has_many :attachments, class_name: 'SellerAttachment'
  has_many :products_images, foreign_key: 'uploader_id', class_name: 'Spree::Image'
  has_many :products, foreign_key: 'user_id', class_name: 'Spree::Product'
  has_many :projects, foreign_key: 'creator_id', inverse_of: :creator
  has_many :projects_collaborated, through: :project_collaborators, source: :project
  has_many :project_collaborators
  has_many :approved_project_collaborations, -> { approved }, class_name: 'ProjectCollaborator'
  has_many :payment_documents, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  has_many :reservations, foreign_key: 'owner_id'
  has_many :recurring_bookings, foreign_key: 'owner_id'
  has_many :relationships, class_name: "UserRelationship", foreign_key: 'follower_id', dependent: :destroy
  has_many :reverse_relationships, class_name: "UserRelationship", foreign_key: 'followed_id', dependent: :destroy
  has_many :reviews
  has_many :requests_for_quotes, -> { where(target_type: ['Transactable', 'Spree::Product']).order('updated_at DESC') }, class_name: 'Support::Ticket'
  has_many :saved_searches, dependent: :destroy
  has_many :shipping_categories, class_name: 'Spree::ShippingCategory'
  has_many :ticket_message_attachments, foreign_key: 'uploader_id', class_name: 'Support::TicketMessageAttachment'
  has_many :tickets, -> { order 'updated_at DESC' }, class_name: 'Support::Ticket'
  has_many :user_industries, dependent: :destroy
  has_many :user_bans
  has_many :user_status_updates
  has_many :wish_lists, dependent: :destroy
  has_many :dimensions_templates, as: :entity

  has_one :blog, class_name: 'UserBlog'
  has_one :current_address, class_name: 'Address', as: :entity

  has_custom_attributes target_type: 'InstanceProfileType', target_id: :instance_profile_type_id

  after_create :create_blog
  after_destroy :perform_cleanup
  before_save :ensure_authentication_token
  before_save :update_notified_mobile_number_flag
  before_create do
    self.instance_profile_type_id ||= PlatformContext.current.present? ? InstanceProfileType.first.try(:id) : InstanceProfileType.where(instance_id: self.instance_id).try(:first).try(:id)
  end

  before_restore :recover_companies

  store :required_fields

  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :companies
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :current_address

  scope :patron_of, lambda { |listing|
    joins(:reservations).where(reservations: { transactable_id: listing.id }).uniq
  }

  scope :by_search_query, lambda { |query|
    where("name ilike ? or email ilike ?", query, query)
  }

  scope :featured, -> { where(featured: true) }

  scope :without, lambda { |users|
    users_ids = users.respond_to?(:pluck) ? users.pluck(:id) : Array.wrap(users).collect(&:id)
    users_ids.any? ? where('users.id NOT IN (?)', users_ids) : all
  }

  scope :ordered_by_email, -> { order('users.email ASC') }

  scope :visited_listing, ->(listing) {
    joins(:reservations).merge(Reservation.confirmed.past.for_listing(listing)).uniq
  }

  scope :hosts_of_listing, ->(listing) {
    where(id: listing.try(:administrator_id)).uniq
  }

  scope :know_host_of, ->(listing) {
    joins(:followers).where(user_relationships: { follower_id: listing.administrator_id }).references(:user_relationships).uniq
  }

  scope :mutual_friends_of, ->(user) {
    joins(:followers).where(user_relationships: { follower_id: user.friends.pluck(:id) }).without(user).with_mutual_friendship_source
  }

  scope :with_mutual_friendship_source, -> {
    joins(:followers).select('"users".*, "user_relationships"."follower_id" AS mutual_friendship_source')
  }

  scope :friends_of, -> (user) {
    joins(
      sanitize_sql(['INNER JOIN user_relationships ur on ur.followed_id = users.id and ur.follower_id = ?', user.id])
    ) if user.try(:id)
  }

  scope :for_instance, -> (instance) {
    where(:'users.instance_id' => instance.id)
  }

  scope :with_date, ->(date) { where(created_at: date) }

  scope :admin,     -> { where(admin: true) }
  scope :not_admin, -> { where("admin iS NULL") }
  scope :with_joined_project_collaborations, -> { joins("LEFT OUTER JOIN project_collaborators pc ON users.id = pc.user_id AND (pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL AND pc.deleted_at IS NULL)")}

  scope :by_topic, -> (topic_ids) do
    if topic_ids.present?
      with_joined_project_collaborations.
      joins(" LEFT OUTER JOIN project_topics pt on pt.project_id = pc.project_id").
      where(pt: {topic_id: topic_ids}).group('users.id')
    end
  end
  scope :filtered_by_custom_attribute, -> (property, values) { where("string_to_array((users.properties->?), ',') && ARRAY[?]", property, values) if values.present? }

  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover_image, CoverImageUploader
  skip_callback :commit, :after, :remove_avatar!
  skip_callback :commit, :after, :remove_cover_image!

  MAX_NAME_LENGTH = 30

  validates :name, :first_name, presence: true
  validate :validate_name_length_from_fullname
  validates :first_name, :middle_name, :last_name, length: { maximum: MAX_NAME_LENGTH }

  # FIXME: This is an unideal coupling of 'required parameters' for specific forms
  #        to the general validations on the User model.
  #        A solution moving forward is to extract the relevant forms into
  #        a 'Form' object containing their own additional validations specific
  #        to their context.
  validates :phone, phone_number: true,
    if: ->(u) {u.phone.present? || u.phone_required}
  validates :mobile_number, phone_number: true,
    if: ->(u) {u.mobile_number.present?}
  validates_presence_of :country_name, if: lambda { phone_required || country_name_required }
  validates_presence_of :mobile_number, if: lambda { mobile_number_required }
  validates_presence_of :last_name, if: lambda { last_name_required }

  validates :current_location, length: { maximum: 50 }
  validates :company_name, length: { maximum: 50 }

  validates_inclusion_of :saved_searches_alerts_frequency, in: SavedSearch::ALERTS_FREQUENCIES

  attr_accessor :custom_validation
  attr_accessor :accept_terms_of_service
  attr_accessor :verify_associated

  validates_associated :companies, if: :verify_associated
  validates_acceptance_of :accept_terms_of_service, on: :create, allow_nil: false, if: lambda { |u| PlatformContext.current.try(:instance).try(:force_accepting_tos) && u.custom_validation }

  validate do |user|
    if user.persisted? && PlatformContext.current.instance.user_info_in_onboarding_flow? && self.custom_validation
      PlatformContext.current.instance.user_required_fields.each do |field|
        if self.respond_to?(field)
          user.errors.add(field, I18n.t('errors.messages.blank')) unless self.send(field).present?
        else
          user.properties.errors.add(field, I18n.t('errors.messages.blank')) unless self.properties[field].present?
        end
      end
    end
  end

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
    :user_validatable, :token_authenticatable, :temporary_token_authenticatable

  attr_accessor :phone_required, :country_name_required, :skip_password, :verify_identity, :mobile_number_required, :last_name_required

  serialize :sms_preferences, Hash
  serialize :instance_unread_messages_threads_count, Hash
  serialize :avatar_transformation_data, Hash

  delegate :to_s, to: :name

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

  def self.featured
    where(featured: true)
  end

  def self.filtered_by_role(values)
    if values.present? && 'Other'.in?(values)
      role_attribute = PlatformContext.current.instance.instance_profile_type.custom_attributes.find_by(name: 'role')
      values += role_attribute.valid_values.reject{ |val| val =~ /Featured|Innovator|Black Belt/i }
    end
    filtered_by_custom_attribute('role', values)
  end

  def apply_omniauth(omniauth)
    self.name = omniauth['info']['name'].presence || ("#{omniauth['info']['first_name']} #{omniauth['info']['last_name']}").presence || ("#{omniauth['info']['First_name']} #{omniauth['info']['Last_name']}").presence || ("#{omniauth['extra'] && omniauth['extra']['raw_info'] && omniauth['extra']['raw_info']['First_name']} #{omniauth['extra'] && omniauth['extra']['raw_info'] && omniauth['extra']['raw_info']['Last_name']}")if name.blank?
    self.email = omniauth['info']['email'].presence || omniauth['extra'] && omniauth['extra']['raw_info'] && omniauth['extra']['raw_info']['email_address'] if email.blank?
    expires_at = omniauth['credentials'] && omniauth['credentials']['expires_at'] ? Time.at(omniauth['credentials']['expires_at']) : nil
    token = (omniauth['credentials'] && omniauth['credentials']['token']).presence || (omniauth['extra'] && omniauth['extra']['raw_info'] && (omniauth['extra']['raw_info']['enterprise_id'].presence || omniauth['extra']['raw_info']['CustID']))
    secret = omniauth['credentials'] && omniauth['credentials']['secret']
    authentications.build(provider: omniauth['provider'],
                          uid: omniauth['uid'],
                          info: omniauth['info'],
                          token: token,
                          secret: secret,
                          token_expires_at: expires_at)
  end

  def all_projects(with_pending = false)
    projects = Project.where("
      creator_id = ? OR
      EXISTS (SELECT 1 from project_collaborators pc WHERE pc.project_id = projects.id AND pc.user_id = ? AND deleted_at IS NULL)
      ",id, id)
    if with_pending
      projects = projects.select(
        ActiveRecord::Base.send(:sanitize_sql_array,
          ["projects.*,
            (SELECT pc.id from project_collaborators pc WHERE pc.project_id = projects.id AND pc.user_id = ? AND ( approved_by_user_at IS NULL OR approved_by_owner_at IS NULL) AND deleted_at IS NULL LIMIT 1) as pending_collaboration
            ",
            id
          ]
        )
      )
    end
    projects
  end


  def category_ids=(ids)
    super(ids.map {|e| e.gsub(/\[|\]/, '').split(',')}.flatten.compact.map(&:to_i))
  end

  def common_categories(category)
    categories & category.descendants
  end

  def create_blog
    build_blog.save
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
    name_from_components(avoid_stack_too_deep).presence || self.read_attribute(:name).to_s.split.collect { |w| w[0] = w[0].capitalize; w }.join(' ')
  end

  def name_from_components(avoid_stack_too_deep)
    return '' if avoid_stack_too_deep
    [first_name, middle_name, last_name].select { |s| s.present? }.join(' ')
  end

  def first_name
    (self.read_attribute(:first_name)) || get_first_name_from_name
  end

  def middle_name
    (self.read_attribute(:middle_name)) || get_middle_name_from_name
  end

  def last_name
    (self.read_attribute(:last_name)) || get_last_name_from_name
  end

  def secret_name
    secret_name = last_name.present? ? last_name[0] : middle_name.try(:[], 0)
    secret_name.present? ? "#{first_name} #{secret_name[0]}." : first_name
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

  def field_blank_or_changed?(field_name)
    # ugly hack, but properties do not respond to _changed, _was etc.
    if self.respond_to?(field_name)
      self.send(field_name).blank? || self.send("#{field_name}_changed?")
    else
      db_field_value = User.find(self.id).properties[field_name]
      self.properties[field_name].blank? || (db_field_value != self.properties[field_name])
    end
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
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::WrongPhoneNumber, self.id)
      update_attribute(:notified_about_mobile_number_issue_at, Time.zone.now)
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

  def social_friends_ids
    authentications.collect{|a| a.social_connection.connections rescue nil}.flatten.compact
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
    Country.find_by_name(country_name) if country_name.present?
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
    if companies.first && companies.first.locations.first
      companies.first.locations.first.listings.first
    end
  end

  def has_listing_without_price?
    listings.any?(&:action_free_booking?)
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

  def generate_spree_api_key
    new_spree_api_key = SecureRandom.hex(32)
    self.update_attribute(:spree_api_key, new_spree_api_key)
    new_spree_api_key
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
      self.save(validate: false)
      true
    else
      false
    end
  end

  def to_liquid
    @user_drop ||= UserDrop.new(self)
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

  def should_render_tutorial?
    if self.tutorial_displayed?
      false
    else
      self.tutorial_displayed = true
      self.save!
    end
  end

  def is_instance_owner?
    self == instance.instance_owner
  end

  def is_location_administrator?
    administered_locations.size > 0
  end

  def iso_country_code
    default_company.try(:iso_country_code)
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

  def can_manage_location?(location)
    location.company && location.company.company_users.where(user_id: self.id).any?
  end

  def can_manage_listing?(listing)
    listing.company && listing.company.company_users.where(user_id: self.id).any?
  end

  def instance_admin?
    @is_instance_admin ||= InstanceAdminAuthorizer.new(self).instance_admin?
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
        company.creator = company.company_users.find { |cu| cu.user_id != self.id }.try(:user)
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
    self.created_companies.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', [self.deleted_at, self.banned_at].compact.first, [self.deleted_at, self.banned_at].compact.first + 30.seconds).each do |company|
      begin
        company.restore(recursive: true)
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

  def approval_request_templates
    @approval_request_templates ||= PlatformContext.current.instance.approval_request_templates.for("User").older_than(created_at)
  end

  def is_trusted?
    approval_request_templates.any? ? (self.approval_requests.approved.count > 0) : true
  end

  def approval_request_acceptance_cancelled!
    listings.find_each(&:approval_request_acceptance_cancelled!)
  end

  def approval_request_approved!
    listings.find_each(&:approval_request_approved!)
  end

  def current_approval_requests
    self.approval_requests.to_a.reject { |ar| !self.approval_request_templates.pluck(:id).include?(ar.approval_request_template_id) }
  end

  def active_for_authentication?
    super && !banned?
  end

  def banned?
    banned_at.present?
  end

  def self.xml_attributes
    self.csv_fields.keys
  end

  def self.csv_fields
    { email: 'User Email', name: 'User Name' }
  end

  def published_blogs
    blog_posts.published
  end

  def recent_blogs
    blog_posts.recent
  end

  def has_published_blogs?
    blog_posts.published.any?
  end

  def registration_in_progress?
    has_draft_listings || has_draft_products
  end

  def registration_completed?
    (companies.first.try(:valid?) || projects.first.present?) && !(has_draft_listings || has_draft_products)
  end

  def has_any_active_products
    companies.any? && companies.first.products.not_draft.any?
  end

  # get_instance_metadata method comes from Metadata::Base
  # you can add metadata attributes to class via: has_metadata accessors: [:support_metadata]
  # please check Metadata::Base for further reference

  def has_draft_listings
    get_instance_metadata("has_draft_listings")
  end

  def has_draft_products
    get_instance_metadata("has_draft_products")
  end

  def has_any_active_listings
    get_instance_metadata("has_any_active_listings")
  end

  def companies_metadata
    get_instance_metadata("companies_metadata")
  end

  def instance_admins_metadata
    return 'analytics' if admin?
    get_instance_metadata("instance_admins_metadata")
  end

  def instance_profile_type_id
    read_attribute(:instance_profile_type_id) || instance_profile_type.try(:id)
  end

  # hack for compatibiltiy reason, to be removed soon
  def profile
    properties
  end

  def cart_orders
    orders.cart
  end

  def cart
    BuySell::CartService.new(self)
  end

  def default_wish_list
    unless wish_lists.any?
      wish_lists.create default: true, name: I18n.t('wish_lists.name')
    end

    wish_lists.default.first
  end

  def question_average_rating(reviews)
    @rating_answers_rating ||= RatingAnswer.where(review_id: reviews.pluck(:id))
      .group(:rating_question_id).average(:rating)
  end

  def recalculate_seller_average_rating!
    seller_average_rating = reviews_about_seller.average(:rating) || 0.0
    self.update_column(:seller_average_rating, seller_average_rating)
    touch
  end

  def recalculate_buyer_average_rating!
    buyer_average_rating = reviews_about_buyer.average(:rating) || 0.0
    self.update_column(:buyer_average_rating, buyer_average_rating)
    touch
  end

  def recalculate_left_as_buyer_average_rating!
    self.update_column(:left_by_buyer_average_rating, Review.left_by_buyer(self).average(:rating) || 0.0)
    touch
  end

  def recalculate_left_as_seller_average_rating!
    self.update_column(:left_by_seller_average_rating, Review.left_by_seller(self).average(:rating) || 0.0)
    touch
  end

  def reset_password!(*args)
    self.skip_custom_attribute_validation = true
    super(*args)
  end

  def reviews_about_seller
    Review.about_seller(self)
  end

  def reviews_about_buyer
    Review.about_buyer(self)
  end

  def ensure_authentication_token!
    ensure_authentication_token
    save(validate: false)
  end

  def self.search_by_query(attributes = [], query)
    if query.present?
      words = query.split.map.with_index{|w, i| ["word#{i}".to_sym, "%#{w}%"]}.to_h

      sql = attributes.map do |attrib|
        if self.columns_hash[attrib.to_s].type == :hstore
          attrib = "CAST(avals(#{quoted_table_name}.\"#{attrib}\") AS text)"
        else
          attrib = "#{quoted_table_name}.\"#{attrib}\""
        end
        words.map do |word, value|
          "#{attrib} ILIKE :#{word}"
        end
      end.flatten.join(' OR ')

      where(ActiveRecord::Base.send(:sanitize_sql_array, [sql, words]))
    else
      all
    end
  end

  def self.custom_order(order, user)
    case order
    when /featured/i
      where(featured: true)
    when /people i know/i
      friends_of(user)
    when /most popular/i
      order('followers_count DESC')
    when /distance/i
      return all unless user
      near(user.current_geolocation, 8_000_000, units: :km, order: 'distance')
    when /number of projects/i
      with_joined_project_collaborations.group('users.id').
        order('count(pc.id) DESC')
    else
      all
    end
  end

  def current_geolocation
    if last_geolocated_location_latitude.to_f.zero? || last_geolocated_location_longitude.to_f.zero?
      current_location
    else
      [last_geolocated_location_latitude, last_geolocated_location_longitude]
    end
  end

  def can_update_feed_status?(record)
    record == self || self.is_instance_owner? || record.try(:creator) === self || record.try(:user_id) === self.id
  end

  def social_friends
    User.where(id: social_friends_ids)
  end

  def nearby_friends(distance)
    User.near([current_address.latitude, current_address.longitude], distance).where.not(id: id)
  end

  def feed_subscribed_to?(object)
    activity_feed_subscriptions.where(followed: object).any?
  end

  def feed_follow!(object)
    activity_feed_subscriptions.where(followed: object).first_or_create!
  end

  def feed_unfollow!(object)
    activity_feed_subscriptions.where(followed: object).destroy_all
  end

  private

  def get_first_name_from_name
    name(true).split[0...1].join(' ')
  end

  def get_middle_name_from_name
    name(true).split.length > 2 ? name(true).split[1] : ''
  end

  def get_last_name_from_name
    name(true).split.length > 1 ? name(true).split.last : ''
  end

  # This validation is necessary due to the inconsistency of the name inputs in the app
  def validate_name_length_from_fullname
    if get_first_name_from_name.length > MAX_NAME_LENGTH
      errors.add(:name, :first_name_too_long, count: User::MAX_NAME_LENGTH)
    end

    if get_middle_name_from_name.length > MAX_NAME_LENGTH
      errors.add(:name, :middle_name_too_long, count: User::MAX_NAME_LENGTH)
    end

    if get_last_name_from_name.length > MAX_NAME_LENGTH
      errors.add(:name, :last_name_too_long, count: User::MAX_NAME_LENGTH)
    end
  end
end
