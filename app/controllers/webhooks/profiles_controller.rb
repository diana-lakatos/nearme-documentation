class Webhooks::ProfilesController < Webhooks::BaseController
  before_action :authenticate

  def webhook
    @user = Authentication.find_by(uid: params[:enterprise_id].to_s).try(:user)
    ProfileUpdateService.new(@user, params).update if @user
    render nothing: true
  end

  def create
    authentication = Authentication.find_by(uid: params[:enterprise_id].to_s)
    unless authentication.present?
      user = User.create!(
        custom_validation: true,
        instance_profile_type_id: InstanceProfileType.default.first.id,
        email: params[:email],
        name: [params[:first_name], params[:last_name]].reject(&:blank?).join(' '),
        password: SecureRandom.hex(8)
      )
      authentication = user.authentications.create!(
        uid: params[:enterprise_id],
        provider: 'saml',
        token: params[:login_id]
      )
    end
    ProfileUpdateService.new(authentication.user, params).update
    render nothing: true
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      token == PlatformContext.current.instance.webhook_token
    end
  end

end
