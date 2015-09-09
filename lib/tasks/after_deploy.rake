namespace :after_deploy do
  desc 'Runs required tasks after deployment'
  task :run => [:environment] do
    ['after_deploy:clear_rails_cache', 'reprocess:css'].each do |task_name|
      p "[#{Time.now}]Invoking: #{task_name}"
      Rake::Task[task_name].invoke
    end
  end

  desc "Clear Rails cache"
  task :clear_rails_cache => [:environment] do
    Rails.cache.clear
    RedisCache.clear
  end
end

