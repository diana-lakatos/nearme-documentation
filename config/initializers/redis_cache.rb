module RedisCache
  class << self
    def client
      if Rails.configuration.redis_cache_client.is_a?(Redis)
        @client ||= Redis.new(Rails.configuration.redis_settings)
      else
        @client ||= Rails.configuration.redis_cache_client
      end
    end
  end
end
