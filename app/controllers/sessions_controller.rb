class SessionsController < Devise::SessionsController

  before_filter :disable_feature, :except => [ :destroy ]

  private

    def disable_feature
      raise ActionController::RoutingError, "Feature disabled"
    end

end
