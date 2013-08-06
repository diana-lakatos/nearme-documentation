class LegacyRedirectHandler < Rack::Rewrite
  def initialize(app)
    super(app) do
      r301 %r{/workplaces/?$},             '/search'
      r301 %r{/workplaces/(.*)},           '/listings/$1'
      r301 '/about',                       '/pages/about'
      r301 '/legal',                       '/pages/legal'
      r301 %r{/apple-touch-icon(.*)?.png}, '/apple-touch-icon-precomposed.png'
      r302 '/support',                     'https://desksnearme.desk.com'
    end
  end
end
