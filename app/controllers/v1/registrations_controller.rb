##
## New user signup
##
class V1::RegistrationsController < V1::BaseController

  def create

    # This is insecure!?
    @user = User.new json_params

    @user.password = json_params["password"]

    if @user.save
      mixpanel.apply_user(@user, :alias => true)
      event_tracker.signed_up(@user, { signed_up_via: 'api', provider: 'native'})
      render json: @user
    else
      puts @user.errors.to_json
      render json: registration_failed_hash(@user), status: 422
    end
  end


  #
  #
  private

  #
  # Result for when registration has failed
  #
  def registration_failed_hash(user)

    # Result hash
    hash = {
      message: "Registration Failed",
      errors: []
    }

    user.errors.each { |k, v|
      hash[:errors] << {
          resource: "User",
          field: k,
          code: (/already been taken/ =~ v ? "already_exists" : "invalid") }
    }

    hash
  end

end
