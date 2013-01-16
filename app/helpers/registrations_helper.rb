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

  def build_link_for(provider)

    class_for_links = "btn btn-blue btn-small"
    if (authentication = Authentication.find_by_provider_and_user_id(provider.downcase, current_user.id))
      # authentication already exists in the database
      if authentication.is_only_login_possibility?
        # only one authentication exists and user has no password defined, so he cannot remove this authentication
        "<span class='#{class_for_links}'>#{provider}</span> (log out and reset password if you would like to disconnect)".html_safe
      else
        # user has other authentications or is able to log in manually, allow to disconnect
        link_to "Disconnect #{provider}", authentication_path(authentication), :method => :delete , :class => class_for_links
      end
    else
      # user is not connected to this social provider yet - no authentication in the database
      link_to "Connect to #{provider}", provider_auth_url(provider.downcase), :class => class_for_links
    end

  end

end
