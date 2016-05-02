class User < ActiveRecord::Base

  include Spree::UserPaymentSource
  include CreationFilter
  include QuerySearchable
  include Approvable

  SORT_OPTIONS = [:all, :featured, :people_i_know, :most_popular, :location, :number_of_projects]
  MAX_NAME_LENGTH = 30
  SMS_PREFERENCES = %w(user_message reservation_state_changed new_reservation)


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

  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover_image, CoverImageUploader

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
   :user_validatable, :token_authenticatable, :temporary_token_authenticatable

  skip_callback :commit, :after, :remove_avatar!
  skip_callback :commit, :after, :remove_cover_image!

  attr_readonly :following_count, :followers_count
  attr_accessor :custom_validation
  attr_accessor :accept_terms_of_service
  attr_accessor :verify_associated
  attr_accessor :skip_password, :verify_identity, :custom_validation, :accept_terms_of_service, :verify_associated,
                :skip_validations_for
  attr_accessor :force_profile

  serialize :sms_preferences, Hash
  serialize :instance_unread_messages_threads_count, Hash
  serialize :avatar_transformation_data, Hash

  delegate :to_s, to: :name

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
  has_many :categories_categorizable, as: :categorizable, through: :user_profiles
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
  has_many :payments, foreign_key: 'payer_id'
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
  has_many :offers, foreign_key: 'creator_id', inverse_of: :creator
  has_many :bids
  has_many :offer_bids, class_name: 'Bid', through: :offers, source: :bids
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
  has_many :user_profiles
  has_many :inappropriate_reports, dependent: :destroy
  has_many :outgoing_phone_calls, foreign_key: :caller_id, class_name: 'PhoneCall'
  has_many :incoming_phone_calls, foreign_key: :receiver_id, class_name: 'PhoneCall'
  has_many :spam_reports

  has_one :blog, class_name: 'UserBlog'
  has_one :current_address, class_name: 'Address', as: :entity

  has_one :seller_profile, -> { seller }, class_name: 'UserProfile'
  has_one :buyer_profile, -> { buyer }, class_name: 'UserProfile'
  has_one :default_profile, -> { default }, class_name: 'UserProfile'
  has_one :communication, ->(user) { where(provider_key: user.instance.twilio_config[:key]) }, dependent: :destroy

  after_create :create_blog
  after_destroy :perform_cleanup
  before_save :ensure_authentication_token
  before_save :update_notified_mobile_number_flag
  before_create :build_profile

  before_create do
    self.instance_profile_type_id ||= PlatformContext.current.present? ? InstanceProfileType.default.first.try(:id) : InstanceProfileType.default.where(instance_id: self.instance_id).try(:first).try(:id)
  end

  before_restore :recover_companies

  store :required_fields

  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :companies
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :current_address
  accepts_nested_attributes_for :seller_profile
  accepts_nested_attributes_for :buyer_profile
  accepts_nested_attributes_for :default_profile
  accepts_nested_attributes_for :bids

  scope :patron_of, lambda { |listing|
    joins(:reservations).where(reservations: { transactable_id: listing.id }).uniq
  }

  scope :by_search_query, lambda { |query|
    where("users.name ilike ? or users.email ilike ? or users.id = ?", query, query, query.remove('%').to_i)
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

  scope :feed_not_followed_by_user, -> (current_user) {
    where.not(id: current_user.feed_followed_users.pluck(:id))
  }

  scope :with_date, ->(date) { where(created_at: date) }

  scope :admin,     -> { where(admin: true) }
  scope :not_admin, -> { where("admin is NULL or admin is false") }
  scope :with_joined_project_collaborations, -> { joins("LEFT OUTER JOIN project_collaborators pc ON users.id = pc.user_id AND (pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL AND pc.deleted_at IS NULL)")}
  scope :created_projects, -> { joins('LEFT OUTER JOIN projects p ON users.id = p.creator_id') }
  scope :featured, -> { where(featured: true) }

  scope :by_topic, -> (topic_ids) do
    if topic_ids.present?
      with_joined_project_collaborations.created_projects.
        joins(" LEFT OUTER JOIN project_topics pt on pt.project_id = pc.project_id OR pt.project_id = p.id ").
        where('pt.topic_id IN (?)', topic_ids).group('users.id')
    end
  end
  scope :filtered_by_custom_attribute, -> (property, values) { where("string_to_array((user_profiles.properties->?), ',') && ARRAY[?]", property, values) if values.present? }
  scope :by_profile_type, -> (ipt_id) { includes(:user_profiles).where(user_profiles: { instance_profile_type_id: ipt_id }) if ipt_id.present? }

  validates_with CustomValidators
  validates :name, :first_name, presence: true
  validate :validate_name_length_from_fullname

  # FIXME: This is an unideal coupling of 'required parameters' for specific forms
  #        to the general validations on the User model.
  #        A solution moving forward is to extract the relevant forms into
  #        a 'Form' object containing their own additional validations specific
  #        to their context.
  validates :phone, phone_number: true,
    if: ->(u) {u.phone.present? || u.validation_for(:phone).try(:is_required?)}
  validates :mobile_number, phone_number: true,
    if: ->(u) {u.mobile_number.present? || u.validation_for(:mobile_number).try(:is_required?)}
  validates_presence_of :country_name, :mobile_number, if:  ->(u)  { u.validation_for(:phone).try(:is_required?) }

  validates_inclusion_of :saved_searches_alerts_frequency, in: SavedSearch::ALERTS_FREQUENCIES

  validates_associated :companies, if: :verify_associated
  validates_acceptance_of :accept_terms_of_service, on: :create, allow_nil: false, if: lambda { |u| PlatformContext.current.try(:instance).try(:force_accepting_tos) && u.custom_validation }

  class << self

    def find_for_database_authentication(warden_conditions)
      where(warden_conditions.to_h).order('external_id NULLS FIRST').first
    end

    # Build a new user, taking into account session information such as Provider
    # authentication.
    def new_with_session(attrs, session)
      user = super
      user.apply_omniauth(session[:omniauth]) if session[:omniauth]
      user
    end

    # FIND undeleted users first (for example for find_by_email finds)
    def with_deleted
      super.order('deleted_at IS NOT NULL, deleted_at DESC')
    end

    # Added back method removed by Diego without which it wouldn't work (throws error)
    # This needs to be checked, why did he remove it?
    def filtered_by_role(values)
      if values.present? && 'Other'.in?(values)
        role_attribute = PlatformContext.current.instance.default_profile_type.custom_attributes.find_by(name: 'role')
        values += role_attribute.valid_values.reject { |val| val =~ /Featured|Innovator|Black Belt/i }
      end

      if values.present? && values.include?("Featured")
        featured
      else
        filtered_by_custom_attribute('role', values)
      end
    end

    def xml_attributes
      self.csv_fields.keys
    end

    def csv_fields
      { email: 'User Email', name: 'User Name' }
    end

    def reset_password_by_token(attributes={})
      original_token       = attributes[:reset_password_token]
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

      recoverable = find_or_initialize_with_error_by(:reset_password_token, reset_password_token)
      recoverable.skip_custom_attribute_validation = true

      if recoverable.persisted?
        if recoverable.reset_password_period_valid?
          recoverable.reset_password(attributes[:password], attributes[:password_confirmation])
        else
          recoverable.errors.add(:reset_password_token, :expired)
        end
      end

      recoverable.reset_password_token = original_token if recoverable.reset_password_token.present?
      recoverable
    end

    def search_by_query(attributes = [], query)
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

    def custom_order(order, user)
      case order
        when /featured/i
          featured
        when /people_i_know/i
          friends_of(user)
        when /most_popular/i
          order('followers_count DESC')
        when /location/i
          return all unless user
          group('addresses.id, users.id').joins(:current_address).select('users.*')
          .merge(Address.near(user.current_address, 8_000_000, units: :km, order: 'distance'))
        when /number_of_projects/i
          order('projects_count + project_collborations_count DESC')
        else
          if PlatformContext.current.instance.is_community?
            order('projects_count + project_collborations_count DESC, followers_count DESC')
          else
            all
          end
      end
    end
  end

  def get_seller_profile
    seller_profile || self.build_seller_profile(instance_profile_type: PlatformContext.current.instance.try("seller_profile_type"))
  end

  def get_buyer_profile
    buyer_profile || self.build_buyer_profile(instance_profile_type: PlatformContext.current.instance.try("buyer_profile_type"))
  end

  def build_profile
    default_profile || self.build_default_profile(instance_profile_type: PlatformContext.current.instance.try("default_profile_type"))
  end

  def custom_validators
    case force_profile
    when 'buyer'
      get_buyer_profile
    when 'seller'
      get_seller_profile
    end
    self.force_profile = nil
    profiles = (UserProfile::PROFILE_TYPES - Array(skip_validations_for).map(&:to_s)).map do |profile_type|
      send("#{profile_type}_profile")
    end.compact
    @custom_validators ||= profiles.map(&:custom_validators).flatten.compact
  end

  def validation_for(field_names)
    field_names = Array(field_names).map(&:to_s)
    custom_validators.select{ |cv| cv.field_name.in?(field_names) }
  end

  def apply_omniauth(omniauth)
    omniauth_coercions = OmniAuthCoercionService.new(omniauth)
    self.name = omniauth_coercions.name if name.blank?
    self.email = omniauth_coercions.email if email.blank?
    self.external_id ||= omniauth_coercions.external_id if PlatformContext.current.instance.is_community?

    authentications.build(
      provider: omniauth['provider'],
      uid: omniauth['uid'],
      info: omniauth['info'],
      token: omniauth_coercions.token,
      secret: omniauth_coercions.secret,
      token_expires_at: omniauth_coercions.expires_at
    )
  end

  def all_projects(with_pending = false)
    # If with_pending is true we want all projects including those to which this user is an unapproved collaborator (added by owner but not approved by this user or added by user but not approved by owner)
    # Projects with pending should only be visible on the users's own profile page
    projects = Project.where("
     creator_id = ? OR
     EXISTS (SELECT 1 from project_collaborators pc WHERE pc.project_id = projects.id AND (pc.user_id = ? OR pc.email = ?) AND (approved_by_user_at IS NOT NULL #{with_pending ? "OR" : "AND"} approved_by_owner_at IS NOT NULL) AND deleted_at IS NULL)
                             ",id, id, email)

    # If the project is pending we add .pending_collaboration to the object (if we requested pending objects as well)
    if with_pending
      projects = projects.select(
        ActiveRecord::Base.send(:sanitize_sql_array,
                                ["projects.*,
           (SELECT pc.id from project_collaborators pc WHERE pc.project_id = projects.id AND (pc.user_id = ? OR pc.email = ?) AND (approved_by_user_at IS NULL OR approved_by_owner_at IS NULL) AND deleted_at IS NULL LIMIT 1) as pending_collaboration
                                 ",
                                 id, email
      ]
                               )
      )
    end
    projects
  end

  def iso_country_code
    iso_country_code = PlatformContext.current.instance.skip_company? ? current_address.try(:iso_country_code) : default_company.try(:iso_country_code)
    iso_country_code.presence || PlatformContext.current.instance.default_country_code
  end

  def all_projects_count
    projects_count + project_collborations_count
  end

  UserProfile::PROFILE_TYPES.each do |profile_type|
    define_method "#{profile_type}_properties" do
      send("#{profile_type}_profile").try(:properties)
    end
  end

  def all_profiles
    UserProfile::PROFILE_TYPES.map do |profile_type|
      send("#{profile_type}_profile")
    end.compact
  end

  alias_method :properties, :default_properties

  def category_ids=(ids)
    default_profile.category_ids = ids
  end

  def category_ids
    default_profile.category_ids
  end

  def categories
    default_profile.categories
  end

  def common_categories(category)
    categories & category.descendants
  end

  def common_categories_json(category)
    JSON.generate(common_categories(category).map { |c| { id: c.id, name: c.translated_name }})
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
    secret_name = secret_name.present? ? "#{first_name} #{secret_name[0]}." : first_name

    if self.properties.try(:is_intel) == true
      secret_name += ' (Intel)'
      secret_name.html_safe
    else
      secret_name
    end
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
    authentications.collect do |a|
      begin
        a.social_connection.try(:connections)
      # We need Exception => e as Authentication::InvalidToken inherits directly from Exception not StandardError
      rescue Exception => e
        nil
      end
    end.flatten.compact
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

  def all_transactables
    if company = default_company
      [company.listings.first, company.products.first, company.offers.first].compact
    end
  end

  def first_transactable
    all_transactables.try(:first)
  end

  def first_listing
    if default_company && default_company.locations.first
      default_company.locations.first.listings.first
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
      "--dnm-token-#{self.id}-#{self.created_at.utc.strftime('%Y-%m-%d %H:%M:%S')}"
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

  def user_messages
    UserMessage.for_user(self)
  end

  def unread_user_message_threads_count_for(instance)
    self.instance_unread_messages_threads_count.fetch(instance.id, 0)
  end

  def listings_in_near(results_size = 3, radius_in_km = 100, without_listings_from_cancelled_reservations = false)
    return [] if PlatformContext.current.nil?

    locations_in_near = Location.includes(:location_address).near(current_address, radius_in_km, units: :km)

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

  def active_for_authentication?
    super && !banned?
  end

  def banned?
    banned_at.present?
  end

  def published_blogs
    blog_posts.published
  end

  def recent_blogs
    blog_posts.recent
  end

  def has_published_posts?
    blog_posts.published.any?
  end

  def registration_in_progress?
    companies.first.try(:draft_at)
  end

  def registration_completed?
    companies.first.try(:completed_at)
  end

  def has_any_active_products
    companies.any? && companies.first.products.not_draft.any?
  end

  # get_instance_metadata method comes from Metadata::Base
  # you can add metadata attributes to class via: has_metadata accessors: [:support_metadata]
  # please check Metadata::Base for further reference

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
    ElasticBulkUpdateJob.perform Transactable, listings.searchable.map{ |listing| [listing.id, { seller_average_rating: seller_average_rating }]}
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

  def can_update_feed_status?(record)
    record == self || self.is_instance_owner? || record.try(:creator) === self || record.try(:user_id) === self.id
  end

  def social_friends
    User.where(id: social_friends_ids)
  end

  def nearby_friends(distance)
    User.where.not(id: id).joins(:current_address).merge(Address.near(current_address, distance, units: :km, order: 'distance')).select('users.*')
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

  def payout_payment_gateway
    if @payment_gateway.nil?
      currency = self.listings.first.try(:currency).presence || 'USD'
      @payment_gateway = instance.payout_gateway(self.iso_country_code, currency)
    end
    @payment_gateway
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
