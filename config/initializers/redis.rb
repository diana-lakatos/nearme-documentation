Resque.redis = if File.exists?("#{Rails.root}/config/redis.yml")
  YAML::load(File.open("#{Rails.root}/config/redis.yml"))[Rails.env]
else
  "localhost:6379"
end
