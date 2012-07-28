require "social"

class V1::AuthenticationsController < V1::BaseController

  def create

    user = User.find_by_email(json_params["email"])
    if user && user.valid_password?(json_params["password"])

      # Authenticated!
      user.ensure_authentication_token!
      render json: { token: user.authentication_token }

    else

      raise DNM::Unauthorized

    end
  end

  def social
    token    = json_params["token"]
    secret   = json_params["secret"]
    provider = ::Social.provider(params[:provider])

    raise DNM::MissingJSONData, "token"  if token.blank?
    raise DNM::MissingJSONData, "secret" if secret.blank? && provider.meta[:auth] == "OAuth 1.0a"

    uid, info = provider.get_user_info(token, secret)

    raise DNM::Unauthorized if uid.blank?

    # Look for a user for those credentials
    auth = Authentication.find_by_provider_and_uid(params[:provider], uid)

    if auth.nil? || auth.user.nil?
      # No Auth? Gonna raise an error...
      if info["email"].present? && User.find_by_email(info["email"])
        # There is a user with that email! Tell the client
        raise DNM::UnauthorizedButUserExists
      else
        raise DNM::Unauthorized
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
