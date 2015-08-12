class NullLogger < Rails::Rack::Logger
  def initialize(app, opts = {})
    @silenced_paths = opts.delete(:silence) || []
    super
  end

  def call(env)
    if env['X-SILENCE-LOGGER'] || @silenced_paths.any? { |path| env['PATH_INFO'].include?(path) }
      Rails.logger.silence do
        @app.call(env)
      end
    else
      super(env)
    end
  end
end
