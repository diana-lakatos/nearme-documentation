class SessionsController < Devise::SessionsController

  def new
    redirect_to authentications_path
  end

  before_filter :disable_feature, :except => [ :new, :destroy ]

  private

    def disable_feature
      raise ActionController::RoutingError, "Feature disabled"
    end

end
