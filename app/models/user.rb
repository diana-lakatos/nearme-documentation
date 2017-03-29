# frozen_string_literal: true
class User < ActiveRecord::Base
  include Searchable

  include Approvable
  include CreationFilter
  include CommunityValidators
  include CreationFilter
  include QuerySearchable
  include UserNameUtility
  include UserProfilesOwnerable
  include TransactablesOwnerable

  SORT_OPTIONS = [:all, :featured, :people_i_know, :most_popular, :location, :number_of_projects].freeze
  SMS_PREFERENCES = %w(user_message reservation_state_changed new_reservation).freeze
  ACCOUNT_STANDINGS = [:active, :deleted, :banned].freeze

  has_paper_trail ignore: [:remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at,
                           :current_sign_in_ip, :last_sign_in_ip, :updated_at, :failed_attempts, :authentication_token,
                           :unlock_token, :locked_at, :browser, :browser_version, :platform,
                           :avatar_versions_generated_at, :last_geolocated_location_longitude,
                           :last_geolocated_location_latitude, :instance_unread_messages_threads_count, :sso_log_out,
                           :avatar_transformation_data, :metadata, :avatar]
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context allow_admin: :admin
  acts_as_tagger

  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :history, :finders, :scoped], scope: :instance
  def slug_candidates
    main_component = if PlatformContext.current.instance.only_first_name_as_user_slug?
                       :first_name
                     else
                       :name
                     end

    [
      main_component,
      [main_component, self.class.last.try(:id).to_i + 1],
      [main_component, rand(1_000_000)]
    ]
  end

  has_metadata accessors: [:support_metadata]

  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover_image, CoverImageUploader

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable,
         :token_authenticatable, :temporary_token_authenticatable, :timeoutable

  skip_callback :commit, :after, :remove_avatar!
  skip_callback :commit, :after, :remove_cover_image!

  attr_readonly :following_count, :followers_count
  attr_accessor :custom_validation
  attr_accessor :must_have_verified_phone_number
  attr_accessor :verify_associated
  attr_accessor :skip_password, :verify_identity, :custom_validation, :verify_associated,
                :skip_validations_for
  attr_accessor :force_profile

  serialize :sms_preferences, Hash
  serialize :instance_unread_messages_threads_count, Hash
  serialize :avatar_transformation_data, Hash

  validate :no_admin_with_such_email_exists, if: :email_changed?
  def no_admin_with_such_email_exists
    errors.add(:email, :taken) if User.admin.where(email: email).exists?
    errors.add(:email, :taken) if external_id.blank? && User.where(email: email).exists?
  end
  validates :email, email: true,
                    uniqueness: { scope: [:instance_id, :external_id] },
                    if: :email_changed?
  validates :email, presence: true

  # strange bug, serialize stops to work if Taggable is included before it
  include Taggable

  belongs_to :domain
  belongs_to :instance
  belongs_to :instance_profile_type, -> { with_deleted }
  belongs_to :partner

  has_many :orders
  has_many :purchases
  has_many :shipping_profiles
  has_many :transactable_line_items, class_name: 'LineItem::Transactable'
  has_many :shipping_addresses, through: :orders, class_name: 'OrderAddress'
  has_many :billing_addresses, through: :orders, class_name: 'OrderAddress'
  has_many :activity_feed_events, as: :followed, dependent: :destroy
  has_many :activity_feed_subscriptions, foreign_key: 'follower_id'
  has_many :activity_feed_subscriptions_as_followed, as: :followed, class_name: 'ActivityFeedSubscription', dependent: :destroy
  has_many :administered_locations, class_name: 'Location', foreign_key: 'administrator_id', inverse_of: :administrator
  has_many :administered_listings, class_name: 'Transactable', through: :administered_locations, source: :listings, inverse_of: :administrator
  has_many :authentications, dependent: :destroy
  has_many :assigned_tickets, -> { order 'updated_at DESC' }, foreign_key: 'assigned_to_id', class_name: 'Support::Ticket'
  has_many :assigned_company_tickets, -> { where(target_type: 'Transactable').order('updated_at DESC') }, foreign_key: 'assigned_to_id', class_name: 'Support::Ticket'
  has_many :approval_request_attachments, foreign_key: 'uploader_id'
  has_many :approval_requests, as: :owner, dependent: :destroy
  has_many :authored_messages, class_name: 'UserMessage', foreign_key: 'author_id', inverse_of: :author
  has_many :blog_posts, class_name: 'UserBlogPost'
  has_many :categories_categorizable, as: :categorizable, through: :user_profiles
  has_many :charges, foreign_key: 'user_id', dependent: :destroy
  has_many :company_users, -> { order(created_at: :asc) }, dependent: :destroy
  has_many :companies, foreign_key: 'creator_id', inverse_of: :creator
  has_many :comments, inverse_of: :creator
  has_many :custom_images, foreign_key: 'uploader_id', inverse_of: :uploader
  has_many :custom_attachments, foreign_key: 'uploader_id', inverse_of: :uploader
  has_many :feed_followers, through: :activity_feed_subscriptions_as_followed, source: :follower
  has_many :feed_followed_transactables, through: :activity_feed_subscriptions, source: :followed, source_type: 'Transactable'
  has_many :feed_followed_topics, through: :activity_feed_subscriptions, source: :followed, source_type: 'Topic'
  has_many :feed_followed_users, through: :activity_feed_subscriptions,  source: :followed, source_type: 'User'
  has_many :feed_following, through: :activity_feed_subscriptions, source: :follower
  has_many :followed_users, through: :relationships, source: :followed
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :instance_clients, as: :client, dependent: :destroy
  has_many :payments, foreign_key: 'payer_id'
  has_many :instance_admins, foreign_key: 'user_id', dependent: :destroy
  has_many :listings, through: :locations, class_name: 'Transactable', inverse_of: :creator
  has_many :listing_orders, class_name: 'Order', source: :orders, foreign_key: :creator_id, inverse_of: :creator
  has_many :created_listings, class_name: 'Transactable', foreign_key: 'creator_id'
  has_many :created_listings_orders, class_name: 'Order', through: :created_listings, source: :orders, inverse_of: :creator
  has_many :listing_reservations, class_name: 'Reservation', through: :listings, source: :reservations, inverse_of: :creator
  has_many :listing_recurring_bookings, class_name: 'RecurringBooking', through: :listings, source: :recurring_bookings, inverse_of: :creator
  has_many :locations, through: :companies, inverse_of: :creator
  has_many :mailer_unsubscriptions
  has_many :photos, foreign_key: 'creator_id', inverse_of: :creator
  has_many :attachments, class_name: 'SellerAttachment'
  has_many :transactables, foreign_key: 'creator_id', inverse_of: :creator
  has_many :transactables_collaborated, through: :transactable_collaborators, source: :transactable
  has_many :approved_transactables_collaborated, through: :transactable_collaborators, source: :transactable
  has_many :transactable_collaborators, dependent: :destroy
  has_many :approved_transactable_collaborations, -> { approved }, class_name: 'TransactableCollaborator'
  has_many :payment_documents, class_name: 'Attachable::PaymentDocument', dependent: :destroy
  has_many :recurring_bookings, foreign_key: 'owner_id'
  has_many :relationships, class_name: 'UserRelationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :reverse_relationships, class_name: 'UserRelationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :reviews
  has_many :requests_for_quotes, -> { where(target_type: 'Transactable').order('updated_at DESC') }, class_name: 'Support::Ticket'
  has_many :saved_searches, dependent: :destroy
  has_many :ticket_message_attachments, foreign_key: 'uploader_id', class_name: 'Support::TicketMessageAttachment'
  has_many :tickets, -> { order 'updated_at DESC' }, class_name: 'Support::Ticket'
  has_many :user_bans
  has_many :user_status_updates, class_name: 'UserStatusUpdate'
  has_many :wish_lists, dependent: :destroy

  # QUESTION: why we need this?
  # has_many :dimensions_templates, as: :entity
  has_many :inappropriate_reports, dependent: :destroy
  has_many :outgoing_phone_calls, foreign_key: :caller_id, class_name: 'PhoneCall'
  has_many :incoming_phone_calls, foreign_key: :receiver_id, class_name: 'PhoneCall'
  has_many :spam_reports

  has_many :groups, foreign_key: 'creator_id', inverse_of: :creator
  has_many :memberships, class_name: 'GroupMember'
  has_many :group_collaborated, -> { GroupMember.approved }, through: :memberships, source: :group
  has_many :all_group_collaborated, through: :memberships, source: :group
  has_many :moderated_groups, -> { GroupMember.approved.moderator }, through: :memberships, source: :group
  has_many :group_members

  has_one :blog, class_name: 'UserBlog'
  has_one :current_address, class_name: 'Address', as: :entity

  has_one :communication, ->(_user) { where(provider_key: PlatformContext.current.instance.twilio_config[:key]) }, dependent: :destroy

  has_one :notification_preference, dependent: :destroy
  has_one :recurring_notification_preference, -> { NotificationPreference.recurring }, class_name: 'NotificationPreference'
  has_one :immediate_notification_preference, -> { NotificationPreference.immediate }, class_name: 'NotificationPreference'

  after_create :create_blog
  after_destroy :perform_cleanup!
  before_save :ensure_authentication_token
  before_save :update_notified_mobile_number_flag
  before_create :get_default_profile

  before_create do
    self.instance_profile_type_id ||= PlatformContext.current.present? ? InstanceProfileType.default.first.try(:id) : InstanceProfileType.default.where(instance_id: instance_id).try(:first).try(:id)
  end

  before_restore :recover_companies

  store :required_fields

  has_one :seller_profile, -> { seller }, class_name: 'UserProfile'
  has_one :buyer_profile, -> { buyer }, class_name: 'UserProfile'
  has_one :default_profile, -> { default }, class_name: 'UserProfile'
  accepts_nested_attributes_for :seller_profile
  accepts_nested_attributes_for :buyer_profile
  accepts_nested_attributes_for :default_profile

  accepts_nested_attributes_for :approval_requests
  accepts_nested_attributes_for :companies
  accepts_nested_attributes_for :transactables
  accepts_nested_attributes_for :current_address
  # need to save nested association automagicall :|
  accepts_nested_attributes_for :user_profiles

  accepts_nested_attributes_for :notification_preference

  scope :patron_of, lambda { |listing|
    joins(:orders).where(orders: { transactable_id: listing.id }).uniq
  }

  scope :by_search_query, lambda { |query|
    where('users.name ilike :query or users.email ilike :query or users.phone like :query or '\
          'users.mobile_number like :query or users.id = :id',
          query: query, id: query.remove('%').to_i)
  }

  scope :featured, -> { where(featured: true) }

  scope :without, lambda { |users|
    users_ids = users.respond_to?(:pluck) ? users.pluck(:id) : Array.wrap(users).collect(&:id)
    users_ids.any? ? where('users.id NOT IN (?)', users_ids) : all
  }

  scope :ordered_by_email, -> { order('users.email ASC') }

  scope :visited_listing, lambda { |listing|
    joins(:orders).merge(Order.reservations.confirmed.past.for_listing(listing)).uniq
  }

  scope :hosts_of_listing, lambda { |listing|
    where(id: listing.try(:administrator_id)).uniq
  }

  scope :know_host_of, lambda { |listing|
    joins(:followers).where(user_relationships: { follower_id: listing.administrator_id }).references(:user_relationships).uniq
  }

  scope :mutual_friends_of, lambda { |user|
    joins(:followers).where(user_relationships: { follower_id: user.friends.pluck(:id) }).without(user).with_mutual_friendship_source
  }

  scope :with_mutual_friendship_source, lambda {
    joins(:followers).select('"users".*, "user_relationships"."follower_id" AS mutual_friendship_source')
  }

  scope :friends_of, lambda { |user|
    if user.try(:id)
      joins(
        sanitize_sql(['INNER JOIN user_relationships ur on ur.followed_id = users.id and ur.follower_id = ?', user.id])
      )
    end
  }

  scope :for_instance, lambda  { |instance|
    where('users.instance_id': instance.id)
  }

  scope :feed_not_followed_by_user, lambda { |current_user|
    where.not(id: current_user.feed_followed_users.pluck(:id))
  }

  scope :with_date, ->(date) { where(created_at: date) }

  scope :admin,     -> { where(admin: true) }
  scope :not_admin, -> { where('admin is NULL or admin is false') }
  scope :with_joined_transactable_collaborations, -> { joins('LEFT OUTER JOIN transactable_collaborators pc ON users.id = pc.user_id AND (pc.approved_by_owner_at IS NOT NULL AND pc.approved_by_user_at IS NOT NULL AND pc.deleted_at IS NULL)') }
  scope :created_transactables, -> { joins('LEFT OUTER JOIN transactables p ON users.id = p.creator_id') }
  scope :featured, -> { where(featured: true) }

  scope :by_topic, ->(topic_ids) do
    if topic_ids.present?
      with_joined_transactable_collaborations.created_transactables
                                             .joins(' LEFT OUTER JOIN transactable_topics pt on pt.transactable_id = pc.transactable_id OR pt.transactable_id = p.id ')
                                             .where('pt.topic_id IN (?)', topic_ids).group('users.id')
    end
  end
  scope :filtered_by_custom_attribute, ->(property, values) { where("string_to_array((user_profiles.properties->?), ',') && ARRAY[?]", property, values) if values.present? }
  scope :by_profile_type, ->(ipt_id) { includes(:user_profiles).where(user_profiles: { instance_profile_type_id: ipt_id }) if ipt_id.present? }
  scope :with_enabled_profile, ->(_ipt_id) { where(user_profiles: { enabled: true }) }

  scope :order_by_array_of_ids, lambda { |user_ids|
    user_ids ||= []
    user_ids_decorated = user_ids.each_with_index.map { |lid, i| "WHEN users.id=#{lid} THEN #{i}" }
    order("CASE #{user_ids_decorated.join(' ')} END") if user_ids.present?
  }
  scope :searchable, -> { not_banned }

  scope :buyers, -> { joins(sanitize_sql_array(['inner join user_profiles up ON up.user_id = users.id AND up.profile_type = ?', UserProfile::BUYER])) }
  scope :sellers, -> { joins(sanitize_sql_array(['inner join user_profiles up ON up.user_id = users.id AND up.profile_type = ?', UserProfile::SELLER])) }

  scope :banned, -> { where('users.banned_at is not null') }
  scope :not_banned, -> { where('users.banned_at is null') }
  scope :active_users, -> { where('users.banned_at is null AND users.deleted_at is null') }

  validates_with CustomValidators

  validate :has_verified_phone_number, if: ->(u) { u.must_have_verified_phone_number }

  # FIXME: This is an unideal coupling of 'required parameters' for specific forms
  #        to the general validations on the User model.
  #        A solution moving forward is to extract the relevant forms into
  #        a 'Form' object containing their own additional validations specific
  #        to their context.
  validates :phone, phone_number: true,
                    if: ->(u) { u.phone.present? || u.validation_for(:phone).try(:is_required?) }
  validates :mobile_number, phone_number: true,
                            if: ->(u) { u.mobile_number.present? || u.validation_for(:mobile_number).try(:is_required?) }
  validates :mobile_number, presence: { if: ->(u) { u.validation_for(:phone).try(:is_required?) || u.sms_notifications_enabled? } }

  validates :saved_searches_alerts_frequency, inclusion: { in: SavedSearch::ALERTS_FREQUENCIES }

  validates_associated :companies, if: :verify_associated

  class << self
    def timeout_in
      return 1.year if PlatformContext.current.instance.timeout_in_minutes.zero?

      PlatformContext.current.instance.timeout_in_minutes.minutes
    end

    def find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      conditions[:email] = conditions[:email].downcase if conditions[:email]
      where(conditions.to_h).order('external_id NULLS FIRST').first
    end

    # Build a new user, taking into account session information such as Provider
    # authentication.
    def new_with_session(attrs, session)
      user = super
      if session[:omniauth]
        user.apply_omniauth(session[:omniauth])
        user.password ||= SecureRandom.hex(16)
      end
      user
    end

    # FIND undeleted users first (for example for find_by_email finds)
    def with_deleted
      super.order('users.deleted_at IS NOT NULL, users.deleted_at DESC')
    end

    # Added back method removed by Diego without which it wouldn't work (throws error)
    # This needs to be checked, why did he remove it?
    def filtered_by_role(values)
      if values.present? && 'Other'.in?(values)
        role_attribute = current_instance.default_profile_type.custom_attributes.find_by(name: 'role')
        values += role_attribute.valid_values.reject { |val| val =~ /Featured|Innovator|Black Belt/i }
      end

      if values.present? && values.include?('Featured')
        featured
      else
        filtered_by_custom_attribute('role', values)
      end
    end

    def xml_attributes
      csv_fields.keys
    end

    def csv_fields
      { email: 'User Email', name: 'User Name' }
    end

    def reset_password_by_token(attributes = {})
      original_token       = attributes[:reset_password_token]
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)

      recoverable = find_or_initialize_with_error_by(:reset_password_token, reset_password_token)
      recoverable.skip_custom_attribute_validation = true
      recoverable.skip_validations_for = %w(default seller buyer)

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
                                       .merge(Address.near(user.current_address, 8_000_000, units: :km, order: 'distance', select: 'users.*'))
      when /number_of_projects/i
        order('transactables_count + transactable_collaborators_count DESC')
      when /custom_attributes./
        parsed_order = order.match(/custom_attributes.([a-zA-Z\.\_\-]*)_(asc|desc)/)
        order(ActiveRecord::Base.send(:sanitize_sql_array, ["cast(user_profiles.properties -> :field_name as float) #{parsed_order[2]}", { field_name: parsed_order[1] }]))
      else
        if current_instance.is_community?
          order('transactables_count + transactable_collaborators_count DESC, followers_count DESC')
        else
          all
        end
      end
    end

    def current_instance
      PlatformContext.current.instance
    end
  end

  def user
    self
  end

  def get_seller_profile
    seller_profile || user_profiles.build(profile_type: 'seller', instance_profile_type: current_instance.try('seller_profile_type'))
  end

  def get_buyer_profile
    buyer_profile || user_profiles.build(profile_type: 'buyer', instance_profile_type: current_instance.try('buyer_profile_type'))
  end

  def get_default_profile
    default_profile || user_profiles.build(profile_type: 'default', instance_profile_type: current_instance.try('default_profile_type'))
  end

  def seller_profile
    user_profiles.detect { |pt| pt.profile_type == 'seller' }
  end

  def default_profile
    user_profiles.detect { |pt| pt.profile_type == 'default' }
  end

  def buyer_profile
    user_profiles.detect { |pt| pt.profile_type == 'buyer' }
  end

  def has_default_profile?
    default_profile.present? && current_instance.default_profile_enabled? && default_profile.has_fields?(FormComponent::INSTANCE_PROFILE_TYPES)
  end

  def has_seller_profile?
    seller_profile.present? && seller_profile.persisted? && current_instance.seller_profile_enabled? && seller_profile.has_fields?(FormComponent::SELLER_PROFILE_TYPES)
  end

  def has_buyer_profile?
    buyer_profile.present? && buyer_profile.persisted? && current_instance.buyer_profile_enabled? && buyer_profile.has_fields?(FormComponent::BUYER_PROFILE_TYPES)
  end

  def custom_validators
    @custom_validators ||= all_current_profiles.map(&:custom_validators).flatten.compact
  end

  def all_current_profiles
    case force_profile
    when 'buyer'
      get_buyer_profile
    when 'seller'
      get_seller_profile
    else
      get_default_profile
    end
    self.force_profile = nil
    @all_current_profiles ||= (UserProfile::PROFILE_TYPES - Array(skip_validations_for).map(&:to_s)).map do |profile_type|
      send("#{profile_type}_profile")
    end.compact
  end

  def custom_attributes_custom_validators
    @custom_attributes_custom_validators ||= all_current_profiles.each_with_object({}) do |profile_type, object|
      object[:"#{profile_type.profile_type}_properties"] = profile_type.custom_attributes_custom_validators.presence || []
    end
  end

  def validation_for(field_names)
    field_names = Array(field_names).map(&:to_s)
    custom_validators.select { |cv| cv.field_name.in?(field_names) }
  end

  def apply_omniauth(omniauth)
    omniauth_coercions = OmniAuthCoercionService.new(omniauth)
    self.name = omniauth_coercions.name if name.blank?
    self.email = omniauth_coercions.email if email.blank?
    self.external_id ||= omniauth_coercions.external_id if current_instance.is_community?

    authentications.build(
      provider: omniauth['provider'],
      uid: omniauth['uid'],
      info: omniauth['info'],
      token: omniauth_coercions.token,
      secret: omniauth_coercions.secret,
      token_expires_at: omniauth_coercions.expires_at
    )
  end

  def all_transactables(with_pending = false)
    # If with_pending is true we want all transactables including those to which this user is an unapproved collaborator (added by owner but not approved by this user or added by user but not approved by owner)
    # Transactables with pending should only be visible on the users's own profile page
    transactables = Transactable.where("
     creator_id = ? OR
     EXISTS (SELECT 1 from transactable_collaborators pc WHERE pc.transactable_id = transactables.id AND (pc.user_id = ? OR pc.email = ?) AND (approved_by_user_at IS NOT NULL #{with_pending ? 'OR' : 'AND'} approved_by_owner_at IS NOT NULL) AND deleted_at IS NULL)
                             ", id, id, email)

    # If the transactable is pending we add .pending_collaboration to the object (if we requested pending objects as well)
    if with_pending
      transactables = transactables.select(
        ActiveRecord::Base.send(:sanitize_sql_array,
                                ["transactables.*,
           (SELECT pc.id from transactable_collaborators pc WHERE pc.transactable_id = transactables.id AND (pc.user_id = ? OR pc.email = ?) AND (approved_by_user_at IS NULL OR approved_by_owner_at IS NULL) AND deleted_at IS NULL LIMIT 1) as pending_collaboration
                                 ",
                                 id, email])
      )
    end
    transactables
  end

  def iso_country_code
    iso_country_code = if current_instance.skip_company?
                         current_address.try(:iso_country_code) || country.try(:iso)
                       else
                         default_company.try(:iso_country_code)
                       end

    iso_country_code.presence || current_instance.default_country_code
  end

  def all_transactables_count
    transactables_count + transactable_collaborators_count
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

  alias properties default_properties

  delegate :category_ids=, to: :default_profile

  delegate :category_ids, to: :default_profile

  delegate :categories, to: :default_profile

  def common_categories(category)
    categories & category.descendants
  end

  def common_categories_json(category)
    JSON.generate(common_categories(category).map { |c| { id: c.id, name: c.translated_name } })
  end

  def create_blog
    build_blog.save
  end

  def cancelled_reservations
    orders.reservations.cancelled
  end

  def rejected_reservations
    orders.reservations.rejected
  end

  def expired_reservations
    orders.reservations.expired
  end

  def confirmed_reservations
    orders.reservations.confirmed
  end

  # Whether to validate the presence of a password
  def password_required?
    # we want to enforce skipping password for instance_admin/users#create
    return false if skip_password == true
    return true if skip_password == false
    # We're changing/setting password, or new user and there are no Provider authentications
    !password.blank? || (new_record? && authentications.empty?)
  end

  # @return [Boolean] whether the user has any active credit cards
  def has_active_credit_cards?
    instance_clients.mode_scope.any? do |i|
      i.payment_gateway.active_in_current_mode? && i.payment_gateway.active_payment_methods.credit_card.any?
    end
  end

  # @return [Boolean] whether the user has any active bank accounts
  def has_active_bank_accounts?
    instance_clients.mode_scope.any? do |i|
      i.payment_gateway.active_in_current_mode? && i.payment_gateway.active_payment_methods.ach.any?
    end
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
    self.password = SecureRandom.hex(8)
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
    if respond_to?(field_name)
      if respond_to?("#{field_name}_changed?")
        send(field_name).blank? || send("#{field_name}_changed?")
      # check if it's association. The idea is to avoid send(field_name) in case the field name is "destroy" etc
      elsif self.class.reflect_on_association(field_name)
        send(field_name).blank? || send(field_name.to_s).changed?
      else
        db_field_value = User.find(id).properties[field_name]
        properties[field_name].blank? || (db_field_value != properties[field_name])
      end
    else
      db_field_value = User.find(id).properties[field_name]
      properties[field_name].blank? || (db_field_value != properties[field_name])
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
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::WrongPhoneNumber, id)
      update_attribute(:notified_about_mobile_number_issue_at, Time.zone.now)
    end
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user, auth = nil)
    relationships.create!(followed_id: other_user.id, authentication_id: auth.try(:id))
  end

  def add_friend(users, auth = nil)
    raise ArgumentError, "Invalid Authentication for User ##{id}" if auth && auth.user != self
    Array.wrap(users).each do |user|
      next if friends.exists?(user)
      friend_auth = auth.nil? ? nil : user.authentications.where(provider: auth.provider).first
      user.follow!(self, friend_auth)
      follow!(user, auth)
    end
  end

  alias add_friends add_friend

  # @return [Array<User>] array of friends for this user (followed users)
  def friends
    followed_users.without(self)
  end

  def friends?
    @count.nil? ? @count = !friends.count.zero? : @count
  end

  def social_friends_ids
    authentications.collect do |a|
      begin
        a.social_connection.try(:connections)
      rescue StandardError => e
        nil
      end
    end.flatten.compact
  end

  # @return [Array<User>] array containing the users that are followed by the administrator of the listing passed as
  #   a parameter and that are also followed by this user
  def friends_know_host_of(listing)
    # TODO: Rails 4 - merge
    friends && User.know_host_of(listing)
  end

  def social_connections
    authentications
  end

  def mutual_friendship_source
    self.class.find_by(id: self[:mutual_friendship_source].to_i) if self[:mutual_friendship_source]
  end

  # @return [Array<User>] array containing users that are followed by the users that this user follows
  def mutual_friends
    self.class.without(self).mutual_friends_of(self)
  end

  def full_email
    "#{name} <#{email}>"
  end

  def country
    Country.find_by(name: country_name) if country_name.present?
  end

  # @return [String, nil] the mobile number with the full international calling prefix
  def full_mobile_number
    return unless mobile_number.present?

    number = mobile_number
    number = "+#{country.calling_code}#{number.gsub(/^0/, '')}" if country.try(:calling_code)
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

  # @return [Company] the default (first) company to which this user belong
  def default_company
    companies.first
  end

  def all_company_transactables
    default_company.listings
  end

  def first_transactable
    all_company_transactables.try(:first)
  end

  def first_listing
    default_company.locations.first.listings.first if default_company && default_company.locations.first
  end

  def has_listing_without_price?
    listings.any?(&:action_free_booking?)
  end

  def log_out!
    update_attribute(:sso_log_out, true)
  end

  def logged_out!
    update_attribute(:sso_log_out, false)
  end

  def generate_payment_token
    new_token = SecureRandom.hex(32)
    update_attribute(:payment_token, new_token)
    new_token
  end

  def verify_payment_token(token)
    return false if payment_token.nil?
    current_token = payment_token
    update_attribute(:payment_token, nil)
    current_token == token
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
    if tutorial_displayed?
      false
    else
      self.tutorial_displayed = true
      save(validate: false)
    end
  end

  def is_instance_owner?
    self == instance.instance_owner
  end

  def is_location_administrator?
    !administered_locations.empty?
  end

  def user_messages
    UserMessage.for_user(self)
  end

  def user_messages_received
    UserMessage.where(thread_recipient: self)
  end

  def unread_user_message_threads_count_for(instance)
    instance_unread_messages_threads_count.fetch(instance.id, 0)
  end

  def listings_in_near(results_size = 3, radius_in_km = 100, without_listings_from_cancelled_reservations = false)
    return [] if PlatformContext.current.nil?

    locations_in_near = Location.includes(:location_address).near(current_address, radius_in_km, units: :km)

    listing_ids_of_cancelled_reservations = orders.reservations.cancelled_or_expired_or_rejected.pluck(:transactable_id) if without_listings_from_cancelled_reservations

    listings = []
    if locations_in_near
      locations_in_near.includes(:listings).each do |location|
        if without_listings_from_cancelled_reservations && !listing_ids_of_cancelled_reservations.empty?
          listings += location.listings.searchable.where('transactables.id NOT IN (?)', listing_ids_of_cancelled_reservations).limit((listings.size - results_size).abs)
        else
          listings += location.listings.searchable.limit((listings.size - results_size).abs)
        end
        return listings if listings.size >= results_size
      end
    end
    listings.uniq
  end

  def can_manage_location?(location)
    location.company && location.company.company_users.where(user_id: id).any?
  end

  def can_manage_listing?(listing)
    listing.company && listing.company.company_users.where(user_id: id).any?
  end

  def instance_admin?
    @is_instance_admin ||= InstanceAdminAuthorizer.new(self).instance_admin?
  end

  # @return [Integer] total number of pageviews for this user's administered locations during the last 30 days
  def administered_locations_pageviews_30_day_total
    scoped_locations = !companies.count.zero? && self == companies.first.creator ? companies.first.locations : administered_locations
    scoped_locations = scoped_locations.with_searchable_listings
    Impression.where('impressionable_type = ? AND impressionable_id IN (?) AND DATE(impressions.created_at) >= ?', 'Location', scoped_locations.pluck(:id), Date.current - 30.days).count
  end

  def unsubscribe(mailer_name)
    mailer_unsubscriptions.create(mailer: mailer_name)
  end

  def unsubscribed?(mailer_name)
    mailer_unsubscriptions.where(mailer: mailer_name).any?
  end

  def perform_cleanup!
    # Record was soft deleted
    if persisted?
      companies.destroy_all
      orders.unconfirmed.find_each(&:user_cancel!)
      created_listings_orders.unconfirmed.find_each(&:reject!)
    else
      # Record is hard deleted
      transactables.each(&:really_destroy!)
      companies.each(&:really_destroy!)
      orders.each(&:really_destroy!)
      created_listings_orders.each(&:really_destroy!)
      # Slugs need to be hard deleted otherwise friendly_id
      # will not find it as the user is gone (uses an inner join)
      # and will decide it's available
      slugs.each(&:really_destroy!)
    end
  end

  def recover_companies
    companies.only_deleted.where('deleted_at >= ? AND deleted_at <= ?', [deleted_at, banned_at].compact.first, [deleted_at, banned_at].compact.first + 30.seconds).find_each do |company|
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
    authentications.where(provider: provider)
                   .where('profile_url IS NOT NULL')
                   .order('created_at asc').last.try(:profile_url)
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

  # @return [Boolean] whether the user has any published blog posts
  def has_published_posts?
    blog_posts.published.any?
  end

  def registration_in_progress?
    companies.first.try(:draft_at)
  end

  def registration_completed?
    companies.first.try(:completed_at)
  end

  # get_instance_metadata method comes from Metadata::Base
  # you can add metadata attributes to class via: has_metadata accessors: [:support_metadata]
  # please check Metadata::Base for further reference

  def companies_metadata
    get_instance_metadata('companies_metadata')
  end

  # @return [String] instance_admins_metadata metadata stored for this user; used for storing
  #   the first permission this user has access to
  def instance_admins_metadata
    return 'analytics' if admin?
    get_instance_metadata('instance_admins_metadata')
  end

  def instance_profile_type_id
    self[:instance_profile_type_id] || instance_profile_type.try(:id)
  end

  # HACK: for compatibiltiy reason, to be removed soon
  def profile
    properties
  end

  def cart_orders
    orders.cart
  end

  def cart
    CartService.new(self)
  end

  # @return [WishList] default wish list for the user, creates it if not present
  def default_wish_list
    wish_lists.create default: true, name: I18n.t('wish_lists.name') unless wish_lists.any?

    wish_lists.default.first
  end

  def question_average_rating(reviews)
    @rating_answers_rating ||= RatingAnswer.where(review_id: reviews.pluck(:id))
                                           .group(:rating_question_id).average(:rating)
  end

  def recalculate_seller_average_rating!
    seller_average_rating = reviews_about_seller.average(:rating) || 0.0
    update_columns(
      seller_average_rating: seller_average_rating, updated_at: Time.now
    )
    ElasticBulkUpdateJob.perform Transactable, listings.searchable.map do |listing|
      [listing.id, { seller_average_rating: seller_average_rating }]
    end
  end

  def recalculate_buyer_average_rating!
    buyer_average_rating = reviews_about_buyer.average(:rating) || 0.0
    update_columns(buyer_average_rating: buyer_average_rating, updated_at: Time.now)
  end

  def recalculate_left_as_seller_average_rating!
    update_columns(
      left_by_seller_average_rating: Review.left_by_seller(self).average(:rating) || 0.0,
      updated_at: Time.now
    )
  end

  def recalculate_left_as_buyer_average_rating!
    left_by_buyer_avg = Review.left_by_buyer(self).active_with_subject(RatingConstants::HOST).average(:rating) || 0.0
    update_columns(
      left_by_buyer_average_rating: left_by_buyer_avg,
      updated_at: Time.now
    )
  end

  def recalculate_product_avarage_rating!
    product_avg = Review.left_by_buyer(self).active_with_subject(RatingConstants::TRANSACTABLE).average(:rating) || 0.0
    update_columns(
      product_average_rating: product_avg,
      updated_at: Time.now
    )
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
    record == self || is_instance_owner? || record.try(:creator) === self || record.try(:user_id) === id
  end

  def social_friends
    User.where(id: social_friends_ids)
  end

  def nearby_friends(distance, excluded_ids = [])
    excluded_ids << id
    excluded_ids = excluded_ids.uniq

    User.where.not(id: excluded_ids).joins(:current_address).merge(Address.near(current_address, distance, units: :km, order: 'distance')).select('users.*')
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

  def payout_payment_gateways
    @payment_gateways = instance.payout_gateways(iso_country_code, all_currencies) if @payment_gateways.nil?
    @payment_gateways
  end

  def all_currencies
    listings.map(&:currency).presence || [instance.default_currency || 'USD']
  end

  def is_available_now?
    if seller_profile.present? && listings.any?(&:time_based_booking?)
      listings.find { |listing| listing.time_based_booking? && listing.open_now? }.present?
    else
      # right now there is no way to determine buyer availability, so we assume he
      # is available at all times and are displaying
      true
    end
  end

  def get_error_messages
    msgs = []

    errors.each do |field|
      msgs += if field =~ /\.properties/
                errors.get(field)
              else
                errors.full_messages_for(field)
              end
    end
    msgs
  end

  def has_verified_number?
    communication.try(:verified?)
  end

  def requires_mobile_number_verifications?
    [default_profile, seller_profile, buyer_profile].map { |p| p.try(:instance_profile_type) }.any? { |ipt| ipt.try(:must_have_verified_phone_number) }
  end

  def host_requires_mobile_number_verifications?
    [default_profile, seller_profile].map { |p| p.try(:instance_profile_type) }.any? { |ipt| ipt.try(:must_have_verified_phone_number) }
  end

  def has_verified_phone_number
    errors.add(:mobile_number, I18n.t('errors.messages.not_verified_phone')) unless has_verified_number?
  end

  def required?(attribute)
    RequiredFieldChecker.new(self, attribute).required?
  end

  def membership_for(group)
    group.memberships.approved.for_user(self).first
  end

  def is_member_of?(group)
    membership_for(group).present?
  end

  def jsonapi_serializer_class_name
    'UserJsonSerializer'
  end

  def transactables_with_message
    Transactable.where(id: (
      user_messages.where(thread_context_type: 'Transactable').reorder('').uniq.pluck(:thread_context_id) |
      user_messages.joins('JOIN transactable_collaborators tc ON tc.id = user_messages.thread_context_id').where(thread_context_type: 'TransactableCollaborator').uniq.reorder('').pluck('tc.transactable_id')))
  end

  def message_context_object
    self
  end

  # @return [Integer, nil] total number of reviews for this user; includes reviews about the user as buyer, as seller,
  #   left by the user as seller, left by the user as buyer, left by the user about transactables
  def total_reviews_count
    ReviewAggregator.new(self).total if RatingSystem.active.any?
  end

  def reviews_counter
    @reviews_counter ||= ReviewAggregator.new(self) if RatingSystem.active.any?
    @reviews_counter
  end

  def get_ui_setting(key)
    populate_ui_settings
    @ui_settings_hash[key]
  end

  def set_ui_setting(key, value)
    populate_ui_settings
    @ui_settings_hash[key] = UiSettings.parse(key, value)
    update_attribute(:ui_settings, JSON.generate(@ui_settings_hash))
  end

  def get_all_ui_settings
    populate_ui_settings
    @ui_settings_hash
  end

  def time_zone
    super || instance&.time_zone.presence || 'Pacific Time (US & Canada)'
  end

  private

  def populate_ui_settings
    @ui_settings_hash ||= JSON.parse ui_settings
  end

  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || first_name_changed? || last_name_changed?
  end

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
    errors.add(:name, :first_name_too_long, count: User::MAX_NAME_LENGTH) if get_first_name_from_name.length > MAX_NAME_LENGTH

    errors.add(:name, :middle_name_too_long, count: User::MAX_NAME_LENGTH) if get_middle_name_from_name.length > MAX_NAME_LENGTH

    errors.add(:name, :last_name_too_long, count: User::MAX_NAME_LENGTH) if get_last_name_from_name.length > MAX_NAME_LENGTH
  end

  def current_instance
    PlatformContext.current.instance
  end
end
