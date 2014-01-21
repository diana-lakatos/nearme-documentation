namespace :update do
  desc "Normalize deleted user's email to normal email address"
  task :normalize_emails => :environment do
    User.only_deleted.each{|user| normalize_user(user)}
  end

  def normalize_user(user)
    user.email = user.email.gsub("deleted_#{user.created_at.to_i}_", '')
    unless user.save
      puts "User #{user.id} can't be updated. Reason: #{user.errors.messages}."
    end
  end
end
