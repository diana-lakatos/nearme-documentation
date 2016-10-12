class V1::AuthenticationsController < V1::BaseController
  def create
    user = User.find_by_email(json_params['email'])
    if user && user.valid_password?(json_params['password'])

      # Authenticated!
      user.ensure_authentication_token!
      render json: { token: user.authentication_token }

    else

      fail DNM::Unauthorized

    end
  end

  def social
    token    = json_params['token']
    secret   = json_params['secret']
    provider = Authentication.provider(params[:provider]).new(token: token, secret: secret, user: current_user)

    fail DNM::MissingJSONData, 'token'  if token.blank?
    fail DNM::MissingJSONData, 'secret' if secret.blank? && provider.is_oauth_1?

    uid = provider.info.uid
    info = provider.info.to_hash

    fail DNM::Unauthorized if uid.blank?

    # Look for a user for those credentials
    auth = Authentication.find_by(provider: params[:provider].try(:to_s), uid: uid.to_s)

    if auth.nil? || auth.user.nil?
      # No Auth? Gonna raise an error...
      if info['email'].present? && User.find_by_email(info['email'])
        # There is a user with that email! Tell the client
        fail DNM::UnauthorizedButUserExists
      else
        fail DNM::Unauthorized
      end
    end

    # Persist!
    auth.info   = info
    auth.token  = token
    auth.secret = secret
    auth.save!

    # Authenticated!
    user = auth.user
    user.ensure_authentication_token!
    render json: { token: user.authentication_token }
  end
end
