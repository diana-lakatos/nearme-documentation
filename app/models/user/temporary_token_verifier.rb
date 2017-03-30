class User::TemporaryTokenVerifier
  # The secret token used as a base for all login tokens.
  #
  # If we ever need to invalidate all oustanding tokens, we can just
  # cycle this secret.
  class_attribute :secret_token
  self.secret_token = '9ad98c608f442abac9783d71d19c08b51abef2c8c36435ec205c1a67d028fd126ed5135f1651befe3629f58c0455f48e7829451715865b9a00b9fdd9b60f540b'

  # Prepare a verifier for a given User
  def initialize(user)
    @user = user
  end

  # Generates an expiring, multi-use login token for the user.
  #
  # Calls to find_user_for_token with this token will match the User until
  # the expires_at date has passed.
  #
  # Returns String
  def generate(expires_at = 12.hours.from_now)
    verifier.generate([@user.id, expires_at.to_i].join('|'))
  end

  def valid?(token)
    user_id, expires_at = verifier.verify(token).split('|')
    user_id.to_i == @user.id && Time.at(expires_at.to_i) > Time.now
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    # If the signature is invalid, then we log the error and match no user.
    Rails.logger.warn("Invalid temporary login token: #{token} for user #{@user.id}")
    false
  end

  # Locate a user for a given token
  #
  # token - A String token returned by a call to #generate
  #
  # Returns a User if matched, or nil if no valid match
  def self.find_user_for_token(token)
    # Since our digest is a function of our app secret and a user secret,
    # we need to locate the User first before we can verify the token.
    user_id, expires_at = extract_data_from_token(token)
    return unless user_id && expires_at

    # If the token has obviously expired, nothing to do.
    return if expires_at <= Time.now

    # Find the user and verify the token
    user = User.find_by_id(user_id)
    return user if user && new(user).valid?(token)

    # If we didn't match anything, then we return nil
    nil
  end

  protected

  # Given a formatted token, extract the data without verifying the message's
  # integrity.
  def self.extract_data_from_token(token)
    # We rely on the formatting of ActiveSupport::MessageVerifier here, so keep
    # in mind that if the messages structure/semantics change we will need to
    # update this.
    data, digest = token.to_s.split('--')
    user_id, expires_at = Base64.decode64(data).split('|')
    [user_id.to_i, Time.at(expires_at.to_i)]
  rescue ArgumentError, TypeError
    [nil, nil]
  end

  # Return a MessageVerifier for generating and verifying message integrity
  def verifier
    ActiveSupport::MessageVerifier.new(secret_token, serializer: StringSerializer)
  end

  # Returns the secret for verifying token integrety for this specific user.
  #
  # We use the encrypted password hash as an extension to our secret key in order
  # to ensure that if the user changes their password, any any outstanding tokens
  # are invalidated.
  def secret_token
    [self.class.secret_token, @user.encrypted_password.to_s].join
  end

  # Simple serializer for ActiveSupport::MessageVerifier to reduce the
  # message wire size.
  module StringSerializer
    def self.load(value)
      value.to_s
    end

    def self.dump(value)
      value.to_s
    end
  end
end
