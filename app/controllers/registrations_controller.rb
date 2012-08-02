class RegistrationsController < Devise::RegistrationsController

  def new
    # Are we coming a provider?
    if session['omniauth'] || session['user_info']
      super
    else
      raise ActionController::RoutingError, "Feature disabled"
    end
  end

  def create
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  def update
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      redirect_to :action => 'edit'
    else
      render :edit
    end
  end

  def destroy
    raise ActionController::RoutingError, "Feature disabled"
  end

  private

    def build_resource(*args)
      super
      if session[:omniauth]
        @user.apply_omniauth(session[:omniauth])
      end
    end

end
