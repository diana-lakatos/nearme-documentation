namespace :sessions do

  desc "Clear expired sessions (more than 2 weeks old)"
  task :cleanup => :environment do
    ActiveRecord::SessionStore::Session.delete_all(['updated_at < ?', Date.current - 2.weeks])
  end

end
