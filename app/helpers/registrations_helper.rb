module RegistrationsHelper
  # Return the id of the wizard currently being used for registration.
  #
  # Registration steps are handled by the Registrations controller to keep the authentication/registration logic
  # isolated. We can render the registration form in a wizard layout.
  def registration_wizard
    case params[:wizard]
    when 'space'
      'space'
    else
      nil
    end
  end
end
