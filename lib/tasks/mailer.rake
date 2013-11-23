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

end
