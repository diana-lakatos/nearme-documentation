config = if File.exists?("#{Rails.root}/config/redis.yml")
  YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
else
  {}
end

Resque.redis = config.symbolize_keys
