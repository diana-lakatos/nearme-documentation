class Webhooks::ProfilesController < Webhooks::BaseController
  before_action :authenticate

  def webhook
    @user = Authentication.find_by_uid(params[:enterprise_id].to_s).try(:user)
    ProfileUpdateService.new(@user, params).update if @user
    render nothing: true
  end

  private

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      token == PlatformContext.current.instance.webhook_token
    end
  end

end
