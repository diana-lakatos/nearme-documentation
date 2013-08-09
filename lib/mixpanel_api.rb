# Our internal wrapper for Mixpanel calls.
#
# Provides an internal interface for triggering Mixpanel calls
# with the correct user data, persisted properties, etc.
#
# Controller requests should initialize this object and pass through
# the relevant session details.
#
# Upon completion of requests, controllers should persist any required
# attributes (i.e. anonymous_identity, session_properties) which should
# be passed back a new instance of this wrapper on subsequent requests.
class MixpanelApi
  # The user form whom the current session represents.
  # This will be used for the mixpanel id.
  attr_reader :current_user

  # If no user is available, then we need an anonymous identity to
  # log events as. This will be generated automatically, or can be
  # provided if it has already been persisted from another session.
  attr_reader :anonymous_identity

  # Hash of session properties that are applied globally to any
  # triggered events.
  attr_reader :session_properties

  # Hash of additional request information that are applied globally to any
  # triggered events.
  attr_reader :request_details

  # Creates a new mixpanel API interface instance
  def self.mixpanel_instance(options = {})
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, options)
  end

  # Initialize a mixpanel wrapper.
  #
  # mixpanel - The basic mixpanel API object
  # options  - A set of additional options relevant to our setup
  #            current_user - The current user object, if the user is logged in.
  #            request_details - Hash with important tracking information like Id of Instance that was used, request host
  #            anonymous_identity - The current anonymous identifier, if any.
  #            session_properties - Hash of persisted global properties to apply to
  #                                 all events.
  #
  def initialize(mixpanel, options = {})
    @mixpanel = mixpanel
    @current_user = options[:current_user]
    @anonymous_identity = options[:anonymous_identity] || (generate_anonymous_identity unless @current_user)
    @session_properties = (options[:session_properties] || {}).with_indifferent_access
    @request_details = (options[:request_details] || {}).with_indifferent_access

    extract_properties_from_params(options[:request_params])
  end

  # Assigns a user to this tracking instance, clearing any 'anonymous' state
  def apply_user(user, options = { :alias => false })
    @current_user = user

    # If we're currently an anonymous identity, we need to alias that
    # to the user user.
    if options[:alias] && anonymous_identity
      @mixpanel.alias(distinct_id, { :distinct_id => anonymous_identity })
      Rails.logger.info "Aliased mixpanel user: #{anonymous_identity} is now #{distinct_id}"
    end

    @anonymous_identity = nil
  end

  # Track an event against the user in the current session.
  def track(event_name, properties, options = {})
    # Assign the user ID for this session
    properties = properties.reverse_merge(
      :distinct_id => distinct_id
    )

    # Assign any global properties
    properties.reverse_merge!(session_properties)
    properties.reverse_merge!(request_details)

    # Trigger tracking the event
    unless should_not_track_employees? && current_user_is_desksnearme_employee?
      @mixpanel.track(event_name, properties, options)
      Rails.logger.info "Tracked mixpanel event: #{event_name}, #{properties}, #{options}"
    else
      Rails.logger.info "Not tracked mixpanel event (current user is employee): #{event_name}, #{properties}, #{options}"
    end
  end

  def current_user_is_desksnearme_employee?
    @current_user && (@current_user.email.include?('@desksnear.me') || @current_user.email.include?('@perchard.com')  || email_belongs_to_employee?(@current_user.email))
  end

  def should_not_track_employees?
    Rails.env.production?
  end

  def email_belongs_to_employee?(email)
    %w(krajek6@gmail.com krajek6@o2.pl josef.simanek@gmail.com mmitchell@uflavor.com patrikjira@gmail.com pllanoc@gmail.com piotr@gega.io).include?(email)
  end

  # Sets global Person properties on the current tracked session.
  def set_person_properties(properties)
    @mixpanel.set(distinct_id, properties)
    Rails.logger.info "Set mixpanel person properties: #{distinct_id}, #{properties}"
  end

  # Track a charge against the user in the current session, incurring the
  # specified revenue for us.
  def charge(amout, time = nil, options = {})
    @mixpanel.track_charge(distinct_id, amount, time, options)
  end

  # Track a charge against a specified user.
  #
  # Note that this doesn't apply the session's distinct ID, as charges
  # may be applied to other users as a result of actions performed by
  # others. See +charge+ to track a charge against the current user.
  def track_charge_against_user(user, amount, time = nil, options = {})
    @mixpanel.track_charge(user.id, amount, time, options)
  end

  # Returns the distinct ID for the user of the current session.
  def distinct_id
    current_user.try(:id) || anonymous_identity
  end

  private

  def generate_anonymous_identity
    SecureRandom.hex(8)
  end

  # Extracts special properties from request parameters. These properties are
  # treated as session/global properties that persist between user requests.
  #
  # We mainly use this to track the request source/campaign.
  def extract_properties_from_params(params)
    return unless params

    [:source, :campaign].each do |param|
      @session_properties[param] = params[param] if params[param]
    end
  end

end

