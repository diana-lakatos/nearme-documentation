##
## New user signup
##
class V1::RegistrationsController < V1::BaseController
  def create
    # This is insecure!?
    @user = User.new(user_params)

    @user.password = user_params['password']

    if @user.save
      render json: @user
    else
      render json: registration_failed_hash(@user), status: 422
    end
  end

  #
  #

  private

  # Return user attributes we can update
  def user_params
    json_params.slice('name', 'email', 'password')
  end

  #
  # Result for when registration has failed

  private

  def registration_failed_hash(user)
    # Result hash
    hash = {
      message: 'Registration Failed',
      errors: []
    }

    user.errors.each do |k, v|
      hash[:errors] << {
        resource: 'User',
        field: k,
        code: (/already been taken/ =~ v ? 'already_exists' : 'invalid')
      }
    end

    hash
  end
end
