config = if File.exists?("#{Rails.root}/config/redis.yml") 
  YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
else
  {}
end

REDIS = ConnectionPool.new(timeout: 1, size: 5) do
  Redis.new(config)
end

Resque.redis = config.symbolize_keys