namespace :special_mailer do

  desc "Send the OpenID discontinued email to all OpenID users"
  task :openid_discontinued => :environment do
    puts "Starting..."
    User.joins(:authentications).where(:authentications => { :provider => 'open_id' }).uniq.find_each do |user|
      begin
        SpecialMailer.openid_support_discontinued(user).deliver
        puts "Emailed User##{user.id}"
      rescue
        puts "Error trying to deliver to User##{user.id}: #{$!.inspect}"
      end
    end
    puts "Finished"
  end
end
