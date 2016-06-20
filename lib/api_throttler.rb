require 'rack/throttle'

class ApiThrottler < Rack::Throttle::Hourly

  def allowed?(request)
    need_throttle?(request) ? count_request(request) <= max_per_window : true
  end

  def call(env)
    status, headers, body = super
    request = Rack::Request.new(env)
    if need_throttle?(request)
      headers['X-RateLimit-Limit']     = max_per_window.to_s
      headers['X-RateLimit-Remaining'] = ([0, max_per_window - (Rails.cache.read(cache_key(request)).to_i rescue 1)].max).to_s
    end
    [status, headers, body]
  end

  def count_request(request)
    key = cache_key(request)
    count = Rails.cache.fetch(key) { 0 }.to_i + 1
    Rails.cache.write(key, count)
    count
  end

  # see https://github.com/bendiken/rack-throttle/blob/master/lib/rack/throttle/limiter.rb#L145
  def client_identifier(request)
    "api-cache-#{PlatformContext.current.instance.id}"
  end

  protected

  # only API calls should be throttled
  def need_throttle?(request)
    # need to take care of language as well, like /pl/api , /en/api etc
    (request.path =~ /^\/api\// || request.path =~ /^\/[a-z]{2}\/api\//).present?
  end

  def max_per_window
    3600
  end

end

