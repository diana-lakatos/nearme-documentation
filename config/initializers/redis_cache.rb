module RedisCache
  class << self
    def client
      @client ||= if Rails.configuration.redis_cache_client == Redis
                    Redis.new(Rails.configuration.redis_settings.merge(db: 2))
                  else
                    Rails.configuration.redis_cache_client
      end
    end

    def clear
      client.flushdb
    end
  end
end
