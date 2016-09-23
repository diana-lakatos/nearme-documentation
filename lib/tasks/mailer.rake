namespace :mailer do

  # Usage: rake mailer:unsubscribe USER=test@example.com MAILER=recurring_mailer/analytics
  desc "Unsubscribe given user from given mailer"
  task :unsubscribe => :environment do
    user = User.find_by_email(ENV['USER'])

    if user
      if user.unsubscribed?(ENV['MAILER'])
        puts "User already unsubscribed (#{ENV['MAILER']})!"
      else
        user.unsubscribe(ENV['MAILER'])
        puts 'User successfully unsubscribed.'
      end
    else
      puts 'User not found ...'
    end
  end

  desc 'Unify emails [user => enquirer, owner => lister ]'
  task unify_emails: [:environment] do
    require_relative './email_unifier_task'
    include EmailUnifierTask

    templates('transactable_mailer/%').each do |template|
      puts "updating #{template.path}"
      update([template.text_body, template.html_body], 'user', 'enquirer')
      update([template.text_body, template.html_body], 'owner', 'lister')

      template.save
    end

    workflow_alerts('transactable_mailer/%').each do |alert|
      puts "updating #{alert.template_path}"
      update(alert.subject, 'user', 'enquirer')
      update(alert.subject, 'owner', 'lister')

      alert.save
    end

    # RECURRING-BOOKING-MAILER

    # listings gonna be fixed in a separate step NM-5844
    templates('recurring_booking_mailer/_listings_in_near.%').each do |template|
      update([template.text_body, template.html_body], 'user', 'lister')

      template.save
    end

    templates('recurring_booking_mailer/%').each do |template|
      update([template.text_body, template.html_body], 'recurring_booking.owner', 'enquirer')

      template.save
    end

    templates('recurring_booking_mailer/notify_guest_%').each do |template|
      update([template.text_body, template.html_body], 'user', 'enquirer')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end

    templates('recurring_booking_mailer/notify_host_%').each do |template|
      update([template.text_body, template.html_body], 'user', 'lister')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end

    workflow_alerts('recurring_booking_mailer/notify_host_of_rejection').each do |alert|
      update(alert.subject, 'user', 'lister')
      alert.save
    end

    # RESERVATION MAILER

    templates('reservation_mailer/notify_host_%').each do |template|
      update([template.text_body, template.html_body], 'user', 'lister')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end

    templates('reservation_mailer/notify_guest_%').each do |template|
      update([template.text_body, template.html_body], 'user', 'enquirer')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end

    workflow_alerts('reservation_mailer/notify_host_of_rejection').each do |alert|
      update(alert.subject, 'host', 'lister')
      alert.save
    end

    # OFFER MAILER

    templates('offer_mailer/notify_host_%').each do |template|
      update([template.text_body, template.html_body], 'user', 'lister')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end

    templates('offer_mailer/notify_guest_%').each do |template|
      update([template.text_body, template.html_body], 'user', 'enquirer')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end

    templates('offer_mailer/pre_booking.%').each do |template|
      update([template.text_body, template.html_body], 'user', 'enquirer')
      update([template.text_body, template.html_body], 'host', 'lister')

      template.save
    end
  end
end
