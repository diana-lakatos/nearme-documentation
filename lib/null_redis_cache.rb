class NullRedisCache
  class << self
    def zadd(_name, _timestamp, data)
      @tracking << data if @tracking
      CacheExpiration.handle_cache_expiration data
    end

    def track
      @tracking = tracking =  []
      yield
      @tracking = nil
      tracking
    end

    def method_missing(_m, *_args, &_block)
      nil
    end

    def zrangebyscore(*_args)
      []
    end
  end
end
