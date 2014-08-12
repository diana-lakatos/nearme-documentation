class LegacyRedirectHandler < Rack::Rewrite
  def initialize(app)
    super(app) do
      r301 %r{.*},                         'http://near-me.com$&', host: "www.near-me.com"
      r301 %r{/workplaces/?$},             '/search'
      r301 %r{/workplaces/(.*)},           '/listings/$1'
      r301 %r{/^reservations\/(\d*)$},     '/dashboard/bookings?id=$1'
      r301 '/legal',                       '/pages/legal'
      r301 %r{/apple-touch-icon(.*)?.png}, '/apple-touch-icon-precomposed.png'
    end
  end
end
