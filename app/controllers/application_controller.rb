class ApplicationController < ActionController::Base

  protect_from_forgery
  layout "application"
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  protected

  def event_tracker
    @event_tracker ||= begin
      Analytics::EventTracker.new(MixpanelApi.new, current_user, params)
    end
  end

  def current_user=(user)
    event_tracker.user = current_user
  end

  def require_ssl
    return if Rails.env.development? || Rails.env.test?

    unless request.ssl?
      redirect_to "https://#{request.host}#{request.fullpath}"
    end
  end

  def stored_url_for(resource_or_scope)
    redirect_url = session[:user_return_to] || root_path
    session[:user_return_to] = nil
    redirect_url
  end

  def after_sign_in_path_for(resource)
    stored_url_for(resource)
  end

  def after_sign_up_path_for(resource)
    stored_url_for(resource)
  end

  def already_signed_in?
    request.xhr? && current_user ?  (render :json => { :redirect => stored_url_for(nil) }) : false
  end

  # Some generic information on wizard for use accross controllers
  WizardInfo = Struct.new(:id, :url)

  # Return an object with information for a given wizard
  def wizard(name)
    return name if WizardInfo === name

    case name.to_s
    when 'space'
      WizardInfo.new(name.to_s, new_space_wizard_url)
    end
  end
  helper_method :wizard

  def redirect_for_wizard(wizard_id_or_object)
    redirect_to wizard(wizard_id_or_object).url
  end

  def not_found
    render "public/404", :status => :not_found
  end

  def rename_flash_messages
    flash[:success] = flash[:notice] if flash[:notice]
  end

end

