class NullLogger < Rails::Rack::Logger
  def initialize(app, opts = {})
    @silenced = opts.delete(:silenced) || []
    super
  end

  def call(env)
    if env['X-SILENCE-LOGGER'] || @silenced.include?(env['PATH_INFO'])
      Rails.logger.silence do
        @app.call(env)
      end
    else
      super(env)
    end
  end
end
