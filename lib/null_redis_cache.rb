class NullRedisCache
  class << self

    def zadd(name, timestamp, data)
      @tracking << data if @tracking
      CacheExpiration.handle_cache_expiration data
    end

    def track
      @tracking = tracking =  []
      yield
      @tracking = nil
      tracking
    end

    def method_missing(m, *args, &block)
      nil
    end

    def zrangebyscore(*args)
      []
    end

  end
end
