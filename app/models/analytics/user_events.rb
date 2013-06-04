module Analytics::UserEvents

  def signed_up(user, custom_options = {})

    # This should alias the anonymous user to the new user account, but it doesn't.
    # https://mixpanel.com/docs/integration-libraries/using-mixpanel-alias
    append_alias user.id

    set user.id, user, custom_options
    track 'Signed Up', user, custom_options
  end

  def logged_in(user, custom_options = {})
    set user.id, user, custom_options
    track 'Logged In', user, custom_options
  end

end

