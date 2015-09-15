namespace :inform_users do
  desc "Send internal message to all users regarding update to Terms of Use"
  task :changes_in_terms_of_use => :environment do
    body = terms_of_use_message
    dnm_instance = Instance.first
    dnm_instance.service_fee_host_percent = 10
    dnm_instance.save!
    platform_context = PlatformContext.new(dnm_instance)

    author = get_author(dnm_instance)

    User.where('instance_id IS NULL OR instance_id = ?', dnm_instance.id).each do |user|
      next if UserMessage.where('author_id = ? AND thread_recipient_id = ? AND body like ?', author.id, user.id, "#{terms_of_use_message[0..100]}%").any?
      um = UserMessage.create({
        thread_context: author,
        thread_owner: author,
        author: author,
        thread_recipient: user,
        body: body,
        instance_id: dnm_instance.id
      })

      begin
        um.send_notification(platform_context)
        puts "User##{user.id} #{user.email} - sent"
      rescue => e
        um.destroy!
        puts "\033[31mUser##{user.id} #{user.email} - sending notification exception #{e.inspect}\033[0m"
      end

      sleep(2)
    end
  end

  def terms_of_use_message
    <<eof
We recently updated our Terms of Use. Please review the new Terms of Use and contact us if you have any questions: https://desksnear.me/pages/terms-of-use

We have added a host service fee of 10%, as at #{Date.current}.

Hosts can see the amount of the service fee and a detailed summary of the transaction via the 'Transfers' section of the host dashboard.

Thank you for being part of the growing Desks Near Me Community!
eof
  end

  def get_author(dnm_instance)
    author = User.where(email: 'support@desksnear.me').first
    if !author
      author = User.new({
        name: 'DesksNearMe',
        email: 'support@desksnear.me',
        password: 'ahgueX0Ahteit*ae$Th5',
        instance_id: dnm_instance.id
      })

      author.save!

      InstanceAdmin.create!(instance_id: dnm_instance.id, user_id: author.id)
    end

    author
  end

end

