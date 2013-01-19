module EmailHelpers
  # Maps a name to an email address. Used by email_steps

  def email_for(to)
    case to

      # add your own name => email address mappings here

    when /^#{capture_model}$/
      model($1).email

    when /^"(.*)"$/
      $1

    else
      to
    end
  end

  def last_email_for(email)
    last_email = mailbox_for(email).last
    last_email.should_not be_nil, "No emails sent to #{email}, expected an email"
    last_email
  end
end

World(EmailHelpers)
