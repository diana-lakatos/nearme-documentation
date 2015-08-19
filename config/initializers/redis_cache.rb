module RedisCache
  class << self
    def client
      @client ||= if Rails.configuration.redis_cache_client == Redis
        Redis.new(Rails.configuration.redis_settings)
      else
        Rails.configuration.redis_cache_client
      end
    end
  end
end
