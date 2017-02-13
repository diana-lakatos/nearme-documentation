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

  def emails_for(email, options={})
    ActionMailer::Base.deliveries.select { |m| m.to.include?(email) &&
      (options[:with_subject].present? ? m.subject.match(options[:with_subject]) : true) }
  end

  def last_email_for(email, options={})
    last_email = emails_for(email, options).sort_by(&:date).last
    last_email.should_not be_nil, "No emails sent to #{email}, expected an email"
    last_email
  end

  def last_email_with_subject(email, text)
    emails_for(email).select { |e| e.subject.include?(text) }.empty?.should be_true
  end
end

World(EmailHelpers)
