require "autoprefixer-rails"

# Compiles our custom instance theme stylesheets, etc.
class Theme::Compiler
  def initialize(theme)
    PlatformContext.current = PlatformContext.new(theme.instance) if theme.instance
    @theme = Theme.find(theme.id)
  end

  # Generates the new stylesheet assets and updates the theme data accordingly.
  def generate_and_update_assets
    raise "Skipping Theme #{theme.id}. Instance for Theme doesn't exist" unless PlatformContext.current

    if cumulative_digest('theme') != @theme.theme_digest
      @theme.compiled_stylesheet = {
        :tempfile => create_compiled_file('theme.scss.erb'),
        :filename => "theme-application-#{Time.zone.now.to_i}.css"
      }
      @theme.theme_digest = cumulative_digest('theme')
    end

    if cumulative_digest('dashboard_theme') != @theme.theme_dashboard_digest
      @theme.compiled_dashboard_stylesheet = {
        :tempfile => create_compiled_file('dashboard_theme.scss.erb'),
        :filename => "theme-dashboard-#{Time.zone.now.to_i}.css"
      }
      @theme.theme_dashboard_digest = cumulative_digest('dashboard_theme')
    end

    if cumulative_digest('new_dashboard_theme') != @theme.theme_new_dashboard_digest
      @theme.compiled_new_dashboard_stylesheet = {
        :tempfile => create_compiled_file('new_dashboard_theme.scss.erb'),
        :filename => "theme-new-dashboard-#{Time.zone.now.to_i}.css"
      }
      @theme.theme_new_dashboard_digest = cumulative_digest('new_dashboard_theme')
    end

    if @theme.changed?
      @theme.skipping_compilation do
        @theme.save!(validate: false)
      end
    end
  ensure
    gzip_tempfile.close rescue nil
    gzip_tempfile.unlink rescue nil
  end

  private

  def cumulative_digest(base_name)
    @digests ||= {}
    return @digests[base_name] if @digests[base_name].present?

    stylesheets_path = Rails.root.join('app', 'assets', 'stylesheets')
    paths = []
    paths << (root_css_path = stylesheets_path.join("#{base_name == 'theme' ? 'application' : 'dashboard'}_dynamic.scss"))
    Dir.glob(stylesheets_path.join('globals') + '*.scss') { |p| paths << p }
    File.open(root_css_path).each do |l|
      if p = l.match(/(theme.*)\"/).try(:captures).try(:at, 0)
        paths << stylesheets_path.join("#{p.sub(/([-_.\w]+)$/, '_\1')}.scss")
      end
    end
    @digests[base_name] = Digest::SHA1.hexdigest(
      Digest::SHA1.hexdigest(compile_erb(erb_template_path("#{base_name}.scss.erb"))) + paths.map { |p| file_digest(p) }.join
    )
  end

  def file_digest(path)
    Digest::SHA1.hexdigest(File.read(path))
  end

  def create_compiled_file(base_file_name)
    path = "#{Dir.tmpdir}/#{base_file_name}-ThemeStylesheet#{@theme.id}"
    FileUtils.touch(path)
    if Rails.env.test? || Rails.env.development?
      File.open(path, 'w') do |gz|
        gz.write AutoprefixerRails.process(render_stylesheet(base_file_name)).css
      end
    else
      compressor = YUI::CssCompressor.new
      Zlib::GzipWriter.open(path, 9) do |gz|
        gz.write compressor.compress(AutoprefixerRails.process(render_stylesheet(base_file_name)).css)
      end
    end
    File.open(path, 'rb')
  end

  def compile_erb(css_template_path)
    @compiled_erbs ||= {}
    return @compiled_erbs[css_template_path] if @compiled_erbs[css_template_path].present?

    # Load the dynamic css template contents
    css_template_content = File.read(css_template_path)

    # Render the ERB component of the template, which outputs owner specific
    # SCSS.
    @compiled_erbs[css_template_path] = ERB.new(css_template_content).result(ERBBinding.new(@theme).get_binding)
  end

  def erb_template_path(file_name)
    Rails.root.join('app', 'assets', 'stylesheets', 'dynamic', file_name)
  end

  def render_stylesheet(file_name)
    css_template_path = erb_template_path(file_name)
    css_content = compile_erb(css_template_path)

    # Use our standard Asset pipeline configuration, as we will be
    # compiling our standard stylesheets with overridden variables specific
    # to the theme.
    environment = Rails.application.assets

    # skip digests (mainly for fonts)
    environment.context_class.digest_assets = false

    context = Rails.application.assets.context_class.new(
      environment, css_template_path.to_s, Pathname.new(css_template_path)
    )

    # Prepare the SCSS template to be compiled
    template = Sprockets::ScssTemplate.new { |tilt|
      # This is a hack to get Tilt providing the right path details to
      # the Sprockets loader.
      #
      # We need to specify a File to correctly handle the relative path
      # contexts within the Sprockets resolver.
      tilt.instance_variable_set('@file', File.open(css_template_path))

      # But we use the ERB compiled version of the template.
      css_content
    }

    template.render(context)

    # Notes from original experimentation...
    #
    # Alternatively we can interact with the Sass compiler directly, but
    # Sprockets has a special include resolver for handling implicit extensions,
    # asset paths, etc.
    #
    # If we go down the route of simplifying/genericizing and tidying up our
    # stylesheets, this will be a much quicker way to compile the SCSS as we
    # will avoid the Sprockets file resolver overhead.
    #
    # sass_renderer = Sass::Engine.new(
    #   css_content, environment.context_class.sass_config.merge(
    #     filename: css_template_path,
    #     syntax: :scss,
    #     importer: importer,
    #     custom: {
    #       resolver: Sass::Rails::Resolver.new(context)
    #     }
    #   )
    # )
    # compiled_css_content = sass_renderer.render
  end

  # Helper class for rendering the ERB stylesheet, providing the relevant helper
  # methods and instance variables.
  class ERBBinding
    attr_reader :theme

    def initialize(theme)
      @theme = theme
    end

    def get_binding
      binding
    end
  end
end
