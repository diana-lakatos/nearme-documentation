module Rack
  # disable CSS3 and jQuery animations in test mode for speed, consistency and avoiding timing issues.
  # Usage for Rails:
  # in config/environments/test.rb
  # config.middleware.use Rack::NoAnimations
  class NoAnimations
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      @status, @headers, @body = @app.call(env)
      return [@status, @headers, @body] unless html?
      response = Rack::Response.new([], @status, @headers)

      @body.each { |fragment| response.write inject(fragment) }
      @body.close if @body.respond_to?(:close)

      response.finish
    end

    private

    def html?
      @headers["Content-Type"] =~ /html/
    end

    def inject(fragment)
      disable_animations = <<-EOF
<script type="text/javascript">(typeof jQuery !== 'undefined') && (jQuery.fx.off = true);</script>
<style>
  * {
     -webkit-transition: none !important;
     transition: none !important;
     -webkit-animation: none !important;
     animation: none !important;
  }
</style>
      EOF
      fragment.gsub(%r{</head>}, disable_animations + "</head>")
    end
  end
end
