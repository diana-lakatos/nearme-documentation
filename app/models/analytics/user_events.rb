module Analytics::UserEvents

  def signed_up(user, custom_options = {})
    alias_user user.id
    set user.id, user, custom_options
    track_event 'Signed Up', user, custom_options
  end

  def logged_in(user, custom_options = {})
    set user.id, user, custom_options
    track_event 'Logged In', user, custom_options
  end

  def incurred_charge(user_id, total_amount_dollars)
    charge user_id, total_amount_dollars
  end

end

