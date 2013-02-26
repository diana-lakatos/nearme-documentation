redis_conf = if File.exists?("#{Rails.root}/config/redis.yml")
  YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
else
  { host: 'localhost', port: 6379 }
end

Resque.redis = Redis.new redis_conf