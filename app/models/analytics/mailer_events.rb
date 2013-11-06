module Analytics::MailerEvents

  def mailer_find_a_desk_clicked(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Find a desk clicked in post_action/sign_up_welcome mail', user, custom_options
  end

  def mailer_list_your_desk_clicked(user, custom_options = {})
    set_person_properties user, custom_options
    track 'List your desk clicked in mail', user, custom_options
  end

  def mailer_social_share(location, custom_options = {})
    track 'Social share in mailer', location, custom_options
  end

  def mailer_view_your_booking_clicked(user, custom_options = {})
    set_person_properties user, custom_options
    track 'View your booking clicked in reservation_mailer/notify_guest_with_confirmation mail', user, custom_options
  end

  def mailer_upload_photos_now_clicked(listing, custom_options = {})
    track 'Upload photos now clicked in mailer', listing, custom_options
  end

  def mailer_manage_desks_clicked(user, custom_options = {})
    set_person_properties user, custom_options
    track 'Manage desks clicked in mail', user, custom_options
  end

end

