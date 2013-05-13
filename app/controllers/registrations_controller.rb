class RegistrationsController < Devise::RegistrationsController

  # NB: Devise calls User.new_with_session when building the new User resource.
  # We use this to apply any Provider based authentications to the user record.
  # This is trigged via Devise::RegistrationsController#build_resource

  # We extend the create action to clear out any stored Provider auth data used during
  # registration.
  before_filter :find_supported_providers, :only => [:edit, :update]
  before_filter :set_return_to, :only => [:new, :create]
  skip_before_filter :require_no_authentication, :only => [:show] , :if => lambda {|c| request.xhr? }

  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }

  def new
    super unless already_signed_in?
  end

  def create
    if User.find_by_email(params[:user][:email])
      set_flash_message :notice, :email_exists, :email => params[:user][:email], :link => (ActionController::Base.helpers.link_to 'Sign In', new_user_session_url(:email => params[:user][:email]), :rel => 'modal.sign-up-modal', :class => "nav-link header-second margin-right ico-login padding-right")
    end if params[:user] && !params[:user][:email].blank?
    super
    AfterSignupMailer.delay({:run_at => 60.minutes.from_now}).help_offer(@user.id) unless @user.new_record?
    # Clear out temporarily stored Provider authentication data if present

    session[:omniauth] = nil unless @user.new_record?
    flash[:redirected_from_sign_up] = true
  end

  def edit
    super
  end

  def update
    if resource.update_with_password(params[resource_name])
      set_flash_message :notice, :updated
      sign_in(resource, :bypass => true)
      redirect_to :action => 'edit'
    else
      render :edit
    end
  end

  def destroy
    raise ActionController::RoutingError, "Feature disabled"
  end

  def avatar
    @user = current_user
    @user.avatar = params[:avatar]
    if @user.save
      render :text => { :url => @user.avatar_url(:thumb).to_s, :destroy_url => destroy_avatar_path }.to_json, :content_type => 'text/plain' 
    else
      render :text => [{:error => @user.errors.full_messages}].to_json,:content_type => 'text/plain', :status => 422
    end
  end

  def destroy_avatar
    @user = current_user
    @user.remove_avatar!
    render :text => {}, :status => 200, :content_type => 'text/plain' 
  end

  def verify
    @user = User.find(params[:id])
    if @user.verify_email_with_token(params[:token])
      sign_in(@user)
      flash[:notice] = "Thanks - your email address has been verified!"
      redirect_to manage_locations_path
    else
      flash[:error] = "Oops - we could not verify your email address. Please make sure that the url has not been malformed"
      redirect_to root_path
    end
  end

  protected

  def is_navigational_format?
    # Wizards don't get flash messages
    if params[:wizard]
      false
    else
      super
    end
  end

  def find_supported_providers
    @supported_providers = Authentication.available_providers
  end

  def set_return_to
    session[:user_return_to] = params[:return_to] if params[:return_to].present?
  end

end
