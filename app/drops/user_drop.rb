# frozen_string_literal: true
class UserDrop < UserBaseDrop
  include CategoriesHelper
  include ReservationsHelper

  # @!method id
  #   @return [Integer] numeric identifier of the user object
  # @!method name
  #   @return [String] Full name for this user
  # @!method friends
  #   @return [Array<UserDrop>] array of friends for this user (followed users)
  # @!method friends_know_host_of
  #   @return [Array<UserDrop>] array containing the users that are followed by the administrator of the listing passed as
  #     a parameter and that are also followed by this user
  # @!method mutual_friends
  #   @return [Array<UserDrop>] array containing users that are followed by the users that this user follows
  # @!method first_name
  #   @return [String] User's first name
  # @!method middle_name
  #   @return [String] User's middle name
  # @!method last_name
  #   @return [String] User's last name
  # @!method reservations_count
  #   Number of reservations placed by this user
  #   @return (see User#reservations_count)
  # @!method email
  #   @return [String] Email address of the user
  # @!method full_mobile_number
  #   @return [String, nil] the mobile number with the full international calling prefix
  # @!method administered_locations_pageviews_30_day_total
  #   @return [Integer] total number of pageviews for this user's administered locations during the last 30 days
  # @!method blog
  #   @return [UserBlogDrop] User's blog
  # @!method country_name
  #   @return [String] Country name for the user
  # @!method phone
  #   @return [String] Phone number for the user
  # @!method current_address
  #   @return [AddressDrop] Address object representing the user's current location
  # @!method is_trusted?
  #   @return [Boolean] whether the object is trusted (approved ApprovalRequest objects for this object, company)
  # @!method has_published_posts?
  #   @return [Boolean] whether the user has any published blog posts
  # @!method seller_properties
  #   @return [Hash] a hash of custom attributes for the seller profile
  # @!method buyer_properties
  #   @return [Hash] a hash of custom attributes for the buyer profile
  # @!method name_with_affiliation
  #   @return [String] formatted string containing the name and user's affiliation;
  #     only applies to the Intel marketplace
  # @!method external_id
  #   @return [String] ID of a user in a third party system, used mainly by bulk upload
  # @!method seller_average_rating
  #   @return [Integer] average rating of this user as a lister
  # @!method buyer_average_rating
  #   @return [Integer] average rating of this user as a enquirer
  # @!method default_wish_list
  #   @return [WishList] default wish list for the user, creates it if not present
  # @!method buyer_profile
  #   @return [UserProfileDrop] Buyer profile for this user if present
  # @!method seller_profile
  #   @return [UserProfileDrop] Seller profile for this user if present
  # @!method tags
  #   @return [TagDrop] array of tags that this user has been tagged with
  # @!method has_friends
  #   @return [Boolean] whether the user has any friends (followed users)
  # @!method transactables_count
  #   @return [Integer] Number of transactables created by this user
  # @!method has_active_credit_cards?
  #   @return [Boolean] whether the user has any active credit cards
  # @!method has_active_bank_accounts?
  #   @return [Boolean] whether the user has any active bank accounts
  # @!method communication
  #   @return [CommunicationDrop] Communication object defining a method for this user to perform a voice call
  # @!method created_at
  #   @return [DateTime] date/time when the user signed up
  # @!method default_company
  #   @return [CompanyDrop] the default (first) company to which this user belong
  # @!method company_name
  #   @return [String] Company name for this user (basic user profile field)
  # @!method instance_admins_metadata
  #   @return [String] instance_admins_metadata metadata stored for this user; used for storing
  #     the first permission this user has access to
  # @!method total_reviews_count
  #   @return [Integer, nil] total number of reviews for this user; includes reviews about the user as buyer, as seller,
  #     left by the user as seller, left by the user as buyer, left by the user about transactables
  # @!method instance_admin?
  #   @return [Boolean] whether the user is an instance admin
  # @!method companies
  #   @return [Array<CompanyDrop>] array of companies belonging to this user
  # @!method user_messages_received
  #   @return [Array<UserMessageDrop>] array of received user messages
  # @!method valid?
  #   @return [Boolean] whether the user is valid (e.g. all required fields filled in etc.)
  # @!method reviews_counter
  #   @return [ReviewAggregatorDrop, nil] {ReviewAggregatorDrop} for current user, if rating systems exist/are enabled for the instance
  # @!method last_sign_in_at
  #   @return [DateTime] date/time when the user last sign in
  # @!method left_by_seller_average_rating
  #   @return averange rating by sellers
  # @!method left_by_buyer_average_rating
  #   @return averange rating by buyers
  # @!method followers_count
  #   @return [Integer] number of user followers
  # @!method following_count
  #   @return [Integer] number of follows given by this user
  # @!method tag_list
  #   @return [Array] search tags
  delegate :id, :name, :friends, :friends_know_host_of, :mutual_friends,
           :first_name, :middle_name, :last_name, :reservations_count,
           :email, :full_mobile_number, :administered_locations_pageviews_30_day_total, :blog,
           :country_name, :phone, :current_address, :is_trusted?,
           :has_published_posts?, :seller_properties, :buyer_properties, :name_with_affiliation,
           :external_id, :seller_average_rating, :default_wish_list, :buyer_profile, :seller_profile,
           :buyer_average_rating,
           :tags, :tag_list, :has_friends, :transactables_count, :completed_transactables_count,
           :has_active_credit_cards?, :has_active_bank_accounts?,
           :communication, :created_at, :has_buyer_profile?, :has_seller_profile?, :default_company,
           :company_name, :instance_admins_metadata, :total_reviews_count, :reviews_counter, :companies, :instance_admin?,
           :avatar,
           :instance_admin?, :user_messages_received, :valid?, :last_sign_in_at, :left_by_seller_average_rating,
           :left_by_buyer_average_rating, :followers_count, :following_count, to: :source

  # @return [String] class name, i.e. 'User'
  def class_name
    'User'
  end

  # @return [String] path to the wishlisting this user
  # @todo -- depracate to url filter
  def wish_list_path
    routes.api_wish_list_items_path(id: @source.id, wishlistable_type: 'User')
  end

  # @return [String] location of the user taken from its associated current_address {AddressDrop} object or, if not present,
  #   from the country_name basic user profile field
  def display_location
    @source.decorate.display_location
  end

  # @!method name_pluralize
  #   @return [String] plural of the user's name
  # @todo -- convert to filter
  delegate :pluralize, to: :name, prefix: true

  # @!method first_name_pluralize
  #   @return [String] plural of the user's first name
  # @todo -- convert to filter
  delegate :pluralize, to: :first_name, prefix: true

  # @return [Boolean] whether the profile of the user has been marked as public
  def public_profile?
    @source.public_profile
  end

  # @return [Boolean] whether the user is authenticated with facebook
  # @todo -- rethink the naming. It doesnt suggest bool at all. Maybe add '?''
  def facebook_connections
    @source.decorate.social_connections_for('facebook').present?
  end

  # @return [Boolean] whether the user is authenticated with linkedin
  # @todo -- rethink the naming. It doesnt suggest bool at all. Maybe add '?''
  def linkedin_connections
    @source.decorate.social_connections_for('linkedin').present?
  end

  # @return [Boolean] whether the user is authenticated with twitter
  # @todo -- rethink the naming. It doesnt suggest bool at all. Maybe add '?''
  def twitter_connections
    @source.decorate.social_connections_for('twitter').present?
  end

  # @return [String] path to the search section in the application
  # @todo -- depracate url for filter
  def search_url
    routes.search_path
  end

  # @return [String] path to the search section in the application
  # @todo -- depracate url for filter
  # @todo Investigate for removal
  def search_url_with_tracking
    routes.search_path
  end

  # @return [Boolean] whether the city where the user booked their
  #   first reservation is present
  # @todo Investigate for removal
  def reservation_city?
    @source.orders.reservations.first.listing.location[:city].present?
  end

  # @return [String] the city where the user booked their first
  #   reservation
  # @todo Investigate for removal
  def reservation_city
    @source.orders.reservations.first.listing.location.city
  end

  # @return [String] string identifying the location where the user booked
  #   their first reservation
  # @todo Investigate for removal
  def reservation_name
    listing_location = @source.orders.reservations.first.listing.location
    reservation_city? ? listing_location.city : listing_location.name
  end

  # @return [String] path to signing in, with the return path set to
  #   the app wizard for adding a new listing to the system
  def space_wizard_list_path
    routes.new_user_session_path(return_to: routes.space_wizard_list_path)
  end

  # @return [String] path to the app wizard for adding a new listing to the system
  # @todo -- depracate url for filter
  def space_wizard_list_url_with_tracking
    routes.space_wizard_list_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] path to the dashboard location for managing all transactables
  # @todo -- depracate url for filter
  def manage_locations_url
    routes.dashboard_company_transactable_types_path
  end

  # @return [String] path to the dashboard location for managing all transactables
  # @todo -- depracate url for filter
  # @todo Investigate for removal
  def manage_locations_url_with_tracking
    routes.dashboard_company_transactable_types_path
  end

  # @return [String] path to the dashboard location for managing all transactables
  # @todo -- depracate url for filter
  def manage_locations_url_with_tracking_and_token
    routes.dashboard_company_transactable_types_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] path to the section in the app for editing a user's profile
  def edit_profile_path
    routes.dashboard_profile_path
  end

  # @return [String] path to the section in the app for editing a user's profile
  # @todo -- depracate url for filter
  def edit_user_registration_url(_with_token = false)
    routes.edit_user_registration_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] path to the section in the app for editing a user's profile, with authentication token
  # @todo -- depracate url for filter
  def edit_user_registration_url_with_token
    routes.edit_user_registration_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] path to the section in the app for editing a user's profile, with authentication token
  # @todo -- depracate url for filter
  # @todo Investigate for removal
  def edit_user_registration_url_with_token_and_tracking
    routes.edit_user_registration_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] url to reset password
  def reset_password_url
    routes.edit_user_password_url(reset_password_token: @source.try(:reset_password_token))
  end

  # @return [String] path to a user's public profile
  # @todo -- depracate url for filter
  def user_profile_url
    routes.profile_path(@source.slug)
  end

  # @return [String] path to reviews in user's public profile
  # @todo -- depracate url for filter
  def reviews_user_profile_url
    routes.profile_path(@source.slug, tab: 'reviews')
  end

  # @return [String] path to services in user's public profile
  # @todo -- depracate url for filter
  def services_user_profile_url
    routes.profile_path(@source.slug, tab: 'services')
  end

  # @return [String] path to blog posts in user's public profile
  # @todo -- depracate url for filter
  def blog_posts_user_profile_url
    routes.profile_path(@source.slug, tab: 'blog_posts')
  end

  # @return [String] path to seller/buyer/default user profile
  # @todo -- depracate url for filter
  def profile_url_for_search
    case @context['transactable_type'].profile_type
    when UserProfile::SELLER
      routes.seller_profile_path(@source.slug)
    when UserProfile::BUYER
      routes.buyer_profile_path(@source.slug)
    else
      routes.profile_path(@source.slug)
    end
  end

  # @return [Array<TransactableDrop>] Listings for the locations for the companies of this user (user's listings)
  def listings
    @source.listings
  end

  # @return [Boolean] whether to show the services tab containing listings created
  #   by the user (used mostly on the buyer/seller profile pages)
  # @todo -- remove per DIY
  def show_services_tab?
    !hide_tab?('services') && @context['listings']
  end

  # @return [Boolean] whether to show the blog tab containing published posts
  #   (used mostly on the buyer/seller profile pages)
  # @todo -- remove per DIY
  def show_blog_tab?
    PlatformContext.current.instance.blogging_enabled?(@source) && @source.blog.try(:enabled?) && !hide_tab?('blog_posts')
  end

  # @return [Array<UserBlogPostDrop>] array of blog posts published by this user
  # @todo -- allow user to set limit by filter
  def published_posts
    @source.published_blogs.limit(5)
  end

  # @return [String] path to viewing reviews left by the user or about the user
  # @todo -- depracate url for filter
  def reviews_collection_path
    routes.reviews_collections_path(@source)
  end

  # @return [String] path to the user's profile
  # @todo -- depracate url for filter
  def profile_url
    urlify(routes.profile_path(@source.slug))
  end

  # @return [String] path to the user's profile with authentication token (projects section)
  # @todo -- depracate url for filter
  def projects_profile_url_with_token
    urlify(routes.profile_path(@source.slug, token_key => @source.try(:temporary_token), anchor: :projects))
  end

  # @return [String] path to the user's profile with authentication token (groups section)
  # @todo -- depracate url for filter
  def groups_profile_url_with_token
    urlify(routes.profile_path(@source.slug, token_key => @source.try(:temporary_token), anchor: :groups))
  end

  # @return [String] path to the section in the application where a user can change his password
  # @todo -- depracate url for filter
  def set_password_url_with_token
    routes.set_password_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] url to the section in the application where a user can change his password
  #   with authentication token
  # @todo -- depracate url for filter
  # @todo Investigate for removal
  def set_password_url_with_token_and_tracking
    routes.set_password_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] path for verifying (confirming) a user's email
  # @todo -- depracate url for filter
  def verify_user_url
    routes.verify_user_path(@source.id, @source.email_verification_token)
  end

  # @return [String] path to the dashboard location for the user reservations
  # @todo -- depracate url for filter
  def bookings_dashboard_url
    routes.dashboard_orders_path
  end

  # @return [Boolean] whether the user's email address is verified
  def is_email_verified?
    @source.verified_at.present?
  end

  # @return [String] path to the section in the application for managing a user's own bookings
  # @todo Investigate for removal
  def bookings_dashboard_url_with_tracking
    routes.dashboard_orders_path
  end

  # @return [String] path to the section in the application for managing a user's own bookings, with authentication token
  # @todo -- depracate url for filter
  def bookings_dashboard_url_with_token
    routes.dashboard_orders_path(token_key => @source.try(:temporary_token))
  end

  # @return [String] path to the section in the application for managing a user's own bookings, with authentication token
  # @todo -- depracate url for filter
  # @todo Investigate for removal
  def bookings_dashboard_url_with_tracking_and_token
    routes.dashboard_orders_path(token_key => @source.try(:temporary_token))
  end

  # @return [Array<TransactableDrop>] listings in and around a user's location, limited to a 100 km radius and a maximum of 3 results
  # @todo -- allow customization via filter
  def listings_in_near
    @source.listings_in_near(3, 100, true)
  end

  # @return [Hash] the user's custom properties list
  def properties
    @source.properties
  end

  # @return [String] url to the "big" version of a user's avatar image
  # @todo -- depracate url for filter
  def avatar_url_big
    asset_url(@source.avatar_url(:big))
  end

  # @return [String] url to the "thumb" version of a user's avatar image
  # @todo -- depracate url for filter
  def avatar_url_thumb
    asset_url(@source.avatar_url(:thumb))
  end

  # @return [String] url to the "bigger" version of a user's avatar image
  # @todo -- depracate url for filter
  def avatar_url_bigger
    asset_url(@source.avatar_url(:bigger))
  end

  # @return [Boolean] whether the marketplace has blogging enabled and the user has a blog enabled for his account
  # @todo -- investigate if needed. If yes, some refactoring would be nice, maybe extraction
  def has_active_blog?
    PlatformContext.current.instance.blogging_enabled?(@source) && @source.blog.try(:enabled?)
  end

  # @return [Hash{String => Hash{String => String, Array}}] returns hash of categories !{ "name" => { "name" => 'translated_name', "children" => [collection of chosen values] } }
  #   for this user object
  # @todo -- this is kind of verbose, am i right?
  def categories
    @categories = build_categories_hash_for_object(@source, Category.users.roots.includes(:children)) if @categories.nil?
    @categories
  end

  # @return [Hash{String => Hash{String => String, Array}}] returns hash of categories !{ "name" => { "name" => 'translated_name', "children" => [collection of chosen values] } }
  #   for this user's buyer profile
  # @todo -- this is too, in a different way :)
  def buyer_categories
    if @categories.nil?
      @categories = build_categories_hash_for_object(@source.buyer_profile, Category.buyers.roots.includes(:children))
    end
    @categories
  end

  # @return [Hash{String => Hash{String => String}}] returns hash of categories !{ "name" => { "name" => 'translated_name', "children" => 'comma separated children' } }
  #   for this user object
  # @todo -- investigate if its possible to leave formatting for users (DIY)
  def formatted_categories
    build_formatted_categories(@source.categories)
  end

  # @return [Hash{String => Hash{String => String, Array}}] returns hash of categories !{ "name" => { "name" => 'translated_name', "children" => [array with children] } }
  #   for this user's buyer profile
  # @todo -- investigate if its possible to leave formatting for users (DIY)
  def formatted_buyer_categories
    build_categories_to_array(@source.buyer_profile.categories) if @source.buyer_profile
  end


  # @return [Hash{String => Array}] returns hash of categories !{ "name" => [array with category names] } }
  #   for this user's buyer profile
  # @todo -- investigate if its possible to leave formatting for users (DIY)
  def buyer_category_tree
    @source.category_tree
  end

  # @return [Hash{String => Hash{String => String, Array}}] returns hash of categories !{ "name" => { "name" => 'translated_name', "children" => [array with children] } }
  #   for this user's seller profile
  # @todo -- investigate if its possible to leave formatting for users (DIY)
  def formatted_seller_categories
    build_categories_to_array(@source.seller_profile.categories) if @source.seller_profile
  end

  # @return [AddressDrop] user's current address taken from the user object, or, if not present
  #   taken from the first configured location for the user
  def address
    @source.current_address.presence || @source.locations.first.try(:location_address)
  end

  # @return [Boolean] whether the currently logged user is this user
  # @todo -- investigate if this can be done differently
  def is_current_user?
    @source.id == @context['current_user'].try(:id)
  end

  # @return [Boolean] an array of custom attributes for the seller profile
  def seller_attributes
    @source.seller_profile.instance_profile_type.custom_attributes.public_display
  end

  # @return [Array<CustomAttributeDrop>] an array of custom attributes for buyer profile
  def buyer_attributes
    @source.buyer_profile.instance_profile_type.custom_attributes.public_display
  end

  # @return [Array<CustomAttributeDrop>] an array of custom attributes for the default profile
  def default_attributes
    @source.default_profile.instance_profile_type.custom_attributes.public_display
  end

  # @return [Array<CustomAttributeDrop>] an array of custom attributes for the default and seller profile
  # @todo -- depracate -- in DIY context
  def default_and_seller_attributes
    default_attributes + seller_attributes
  end

  # @return [Array<CustomAttributeDrop>] an array of custom attributes for the default and buyer profile
  # @todo -- depracate -- in DIY context
  def default_and_buyer_attributes
    default_attributes + buyer_attributes
  end

  # @return [Hash{String => Object}] a hash with all the user's custom properties (taken from the default, buyer and seller profiles)
  def all_properties
    @all_properties ||= @source.default_properties.to_h.merge(@source.seller_properties.to_h.merge(@source.buyer_properties.to_h))
  end

  # @return [Boolean] whether the user is "twitter connected" to the site
  # @todo -- rethink name -- maybe use rails convention: *_connected?
  # also ive seen already in couple places things that are connected to social networks,
  # maybe a separate drop/filter would be nice
  # or maybe it is just unnecessary and can be removed
  def is_twitter_connected
    social_connections.where(provider: 'twitter').exists?
  end

  # @return [Boolean] whether the user is "facebook connected" to the site
  # @todo -- rethink name -- maybe use rails convention: *_connected?
  # also ive seen already in couple places things that are connected to social networks,
  # maybe a separate drop/filter would be nice
  # or maybe it is just unnecessary and can be removed
  def is_facebook_connected
    social_connections.where(provider: 'facebook').exists?
  end

  # @return [Boolean] whether the user is "linkedin connected" to the site
  # @todo -- rethink name -- maybe use rails convention: *_connected?
  # also ive seen already in couple places things that are connected to social networks,
  # maybe a separate drop/filter would be nice
  # or maybe it is just unnecessary and can be removed
  def is_linkedin_connected
    social_connections.where(provider: 'linkedin').exists?
  end

  # @return [String] formatted string representation of when the user signed up
  # @todo -- extract formatting to filter
  def member_since
    I18n.l(@source.created_at.to_date, format: :short)
  end

  # @return [Integer] total count of reviewable reservations (confirmed and archived)
  def completed_host_reservations_count
    @source.listing_orders.reservations.reviewable.count
  end

  # @return [Integer] total count of reviewable orders (confirmed and archived)
  def completed_orders_count
    @source.orders.reviewable.count
  end

  # @return [String, nil] click to call button for this user if enabled for this
  #   marketplace; just the first name is shown
  # @todo -- depracate in favor of DIY - especially looking at logic in this helper, this will be very hard to document at all
  def click_to_call_button_first_name
    build_click_to_call_button_for_user(@source, first_name: true)
  end

  # @return [Boolean] whether or not the user has a buyer profile set up
  # @todo -- depracate - or at least rename to rails convention
  def has_buyer_profile?
    @source.buyer_profile.present? && @source.buyer_profile.persisted?
  end

  # @return [Boolean] whether or not the user has a seller profile set up
  # @todo -- depracate - or at least rename to rails convention
  def has_seller_profile?
    @source.seller_profile.present? && @source.seller_profile.persisted?
  end

  # @return [Boolean] whether the user only has a buyer profile implemented to make things easier as Liquid does not
  #   have a not operator
  # @todo -- depracate - or at least rename to rails convention
  def only_buyer_profile?
    has_buyer_profile? && !has_seller_profile?
  end

  # @return [Boolean] whether the user only has a seller profile implemented to make things easier as Liquid does not
  #   have a not operator
  # @todo -- depracate - or at least rename to rails convention
  def only_seller_profile?
    !has_buyer_profile? && has_seller_profile?
  end

  # @return [Boolean] whether the user has any verified merchant account (attached to his first company)
  # @todo -- verify logic -- it smells a lot. If correct, i recommend renaming with rails conv. in mind
  def has_verified_merchant_account
    @source.companies.first.try(:merchant_accounts).try(:any?, &:verified?)
  end

  # @return [Boolean] whether the user has pending transactables
  #   (created by the currently logged in user, in the pending state, and to which this user is not a collaborator)
  # @todo -- depracate - user can check it in liquid
  def has_pending_transactables?
    pending_transactables.any?
  end

  # @return [Integer] numer of created listings (in the 'completed') state
  # @todo -- depracate -- maybe allow filtering listings by state using filter .created_listings | filter: 'completed' | size
  def completed_transactables_count
    @source.created_listings.with_state(:completed).count
  end

  # @return [Array<TransactableDrop>] array of pending transactables for the currently logged in user
  #   (created by the currently logged in user, in the pending state)
  # @todo -- SQL query in drop -- .try(:hard).smell(self) ;-) Additionally, it should be in transactable drop
  def pending_transactables_for_current_user
    Transactable.where(creator_id: @context['current_user'].id).with_state(:pending)
                .joins("LEFT Outer JOIN transactable_collaborators tc on
      tc.transactable_id = transactables.id and tc.user_id = #{@source.id} and
      tc.deleted_at is NULL")
  end

  # @return [Array<Transactable>] array of pending transactables for the user
  #   (created by the currently logged in user, in the pending state, and to which this user is not a collaborator)
  # @todo -- same as above
  def pending_transactables
    pending_transactables_for_current_user.where('tc.id is NULL')
  end

  # @return [Array<Transactable>] array of pending transactables for the user
  #   (in the pending state, and with no collaborators)
  def transactables_without_collaborators
    @source.transactables.with_state(:pending)
      .where(TransactableCollaborator.where("transactable_collaborators.transactable_id = transactables.id").exists.not)
  end

  # @return [Array<TransactableDrop>] array of pending transactables for the user to which the user is a collaborator
  #   (created by the currently logged in user, in the pending state, and to which this user is a collaborator)
  # @todo -- same as above
  def pending_collaborated_transactables
    pending_transactables_for_current_user.where('tc.id is NOT NULL')
  end

  # @return [Integer] number of unconfirmed received orders
  # @todo Investigate for removal; the method doesn't appear to do what its name says
  # @todo -- move to orders drop?
  def unconfirmed_received_orders_count
    @unconfirmed_received_orders_count ||= @source.listing_orders.unconfirmed.count
  end

  # @return [Boolean] whether the user has any companies created
  # @todo -- deprecate -- current_user.companies.size > 0
  def has_company?
    @source.companies.present?
  end

  # @return [Integer, Boolean] ID of the user's first company, false if not present
  # @todo -- deprecate, DIY
  def company_id
    has_company? && @source.companies.first.id
  end

  # @return [Boolean] whether the user completed the registration process
  # @todo -- explain what does it mean to have completed registration process. Logic in model smells
  def registration_completed?
    !!@source.registration_completed?
  end

  # @return [Integer, nil] total orders for this user (received - not in the 'inactive' state, unconfirmed;
  #   and placed - unconfirmed and not archived); nil if the total count is 0
  # @todo -- move to reservations drop?
  def reservations_count
    count = reservations_count_for_user(@source)
    count > 0 ? count : nil
  end

  # @return [Array<TransactableDrop>] transactables created by the currently logged in user to
  #   which this user object is a collaborator
  def collaborator_transactables_for_current_user
    @source.transactables_collaborated.where(creator_id: @context['current_user'].try(:id))
  end

  # @return [String] path for generating an inappropriate report for this user
  # @todo -- deprecate in favor of filter
  def inappropriate_report_path
    routes.inappropriate_report_path(id: @source.id, reportable_type: 'User')
  end

  # @return [Integer] total count of unread messages in user inbox
  # @todo - deprecate -- DIY
  def unread_messages_count
    @source.unread_user_message_threads_count_for(PlatformContext.current.instance)
  end

  # @return [Integer] total count of seller_pending_transactables_count and buyer_pending_transactables_count
  # @todo - deprecate -- DIY and/or move to transactable drop
  def pending_transactables_count
    seller_pending_transactables_count || buyer_pending_transactables_count
  end

  # @return [Integer, nil] count of created transactables in the 'pending' state if the user has a seller profile, nil
  #   otherwise
  # @todo - deprecate -- DIY and/or move to transactable drop
  def seller_pending_transactables_count
    @source.transactables.with_state(:pending).count if has_seller_profile?
  end

  # @return [Integer, nil] count of transactables to which this user is a collaborator, in the 'pending' state
  #   if the user has a buyer profile, nil otherwise
  # @todo Investigate for removal (method is not used and does not appear to provide a useful function, also
  #   inconsistently named)
  def buyer_pending_transactables_count
    @source.approved_transactables_collaborated.with_state(:pending).count if has_buyer_profile?
  end

  # @return [String] path to the place in admin indicated by the instance_admins_metadata
  #   stored for the user (usually the first permission the user has access to)
  # @todo -- deprecate in favor of filter
  def user_menu_instance_admin_path
    users_instance_admin = '_manage_blog' if @source.instance_admins_metadata == 'blog'
    users_instance_admin = '_support_root' if @source.instance_admins_metadata == 'support'
    routes.send("instance_admin#{users_instance_admin}_path")
  end

  # @return [Boolean] whether to show the blog menu (used in liquid views rendering navigation items)
  #   true if the blogging functionality is allowed for the type of user that this user has
  # @todo -- deprecate -- DIY
  def show_blog_menu?
    (!platform_context_decorator.instance.split_registration? && platform_context_decorator.instance.user_blogs_enabled) ||
      (has_seller_profile? && @source.instance.lister_blogs_enabled || has_buyer_profile? && @source.instance.enquirer_blogs_enabled)
  end

  private

  # @return [Array<Authentication>] array of authentication objects representing authentications with 3rd party
  #   sites for this user (Twitter, Facebook etc.)
  def social_connections
    @social_connections_cache ||= @source.social_connections
  end

  def asset_url(*args)
    ActionController::Base.helpers.asset_url(*args)
  end
end
