# Compiles our custom instance theme stylesheets, etc.
class Theme::Compiler
  def initialize(theme)
    @theme = theme
  end

  # Generates the new stylesheet assets and updates the theme data accordingly.
  def generate_and_update_assets
    begin
      tempfile = Tempfile.new("ThemeStylesheet#{@theme.id}")
      tempfile.write render_stylesheet

      @theme.compiled_stylesheet = {
        :tempfile => tempfile,
        :filename => "theme-#{Time.now.to_i}.css",
        :content_type => "text/css"
      }

      @theme.skipping_compilation do
        @theme.save!(validate: false)
      end
    ensure
      tempfile.close rescue nil
      tempfile.unlink rescue nil
    end
  end

  private

  def render_stylesheet
    # Load the dynamic css template contents
    css_template_path = Rails.root.join(
      'app', 'assets', 'stylesheets', 'dynamic', 'theme.scss.erb'
    )
    css_template_content = File.read(css_template_path)

    # Render the ERB component of the template, which outputs owner specific
    # SCSS.
    css_content = ERB.new(css_template_content).result(
      ERBBinding.new(@theme).get_binding
    )

    # Use our standard Asset pipeline configuration, as we will be
    # compiling our standard stylesheets with overridden variables specific
    # to the theme.
    environment = Rails.application.assets
    context = Rails.application.assets.context_class.new(
      environment, css_template_path.to_s, Pathname.new(css_template_path)
    )

    # Prepare the SCSS template to be compiled
    template = Sass::Rails::ScssTemplate.new { |tilt|
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
