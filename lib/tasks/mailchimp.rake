namespace :mailchimp do
  namespace :export do
    desc "Exports unsynchronized users to mailchimp"
    task :users => :environment do 
      Rails.application.routes.default_url_options[:host] = 'desksnear.me'
      Rails.application.routes.default_url_options[:protocol] = 'https'
      result = MAILCHIMP.export_users
      puts "#{result[:new]} users we exported"
      puts "#{result[:updated]} users we updated"
      puts "#{User.count - result[:new] - result[:updated]} users were skipped"
    end
  end

end
