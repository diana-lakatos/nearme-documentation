module Utils
  class CustomTemplateLoader

    def initialize(custom_theme, root_template_path)
      @custom_theme = custom_theme
      @custom_theme.instance.set_context!
      @root_template_path = root_template_path
    end

    def load!
      load_views!
      load_all_assets!
    end

    protected

    def load_views!
      Dir.glob("#{@root_template_path}/views/**/*\.html\.liquid").each do |p|
        relative_path = p.sub("#{@root_template_path}/views/", '').sub('.html.liquid', '')
        components = relative_path.split('/')
        if components.last[0] == '_'
          partial = true
          components[components.length - 1] = components.last[1..-1]
          relative_path = components.join('/')
        else
          partial = false
        end
        instance_view = @custom_theme.instance_views.where(instance_id: @custom_theme.instance_id, path: relative_path, partial: partial, handler: :liquid, format: :html, view_type: InstanceView::CUSTOM_VIEW).first_or_initialize do |iv|
          iv.locales << Locale.all
          iv.transactable_types << TransactableType.all
          iv.view_type = InstanceView::CUSTOM_VIEW
        end
        instance_view.body = File.read(p)
        instance_view.save!
      end
    end

    def load_all_assets!
      Dir.glob("#{@root_template_path}/assets/css/**/*").each do |p|
        load_text!(p, CustomThemeAsset::ThemeCssFile)
      end

      Dir.glob("#{@root_template_path}/assets/js/**/*").each do |p|
        load_text!(p, CustomThemeAsset::ThemeJsFile)
      end

      Dir.glob("#{@root_template_path}/assets/images/**/*").each do |p|
        load_asset!(p, CustomThemeAsset::ThemeImageFile)
      end

      Dir.glob("#{@root_template_path}/assets/font/**/*").each do |p|
        load_asset!(p, CustomThemeAsset::ThemeFontFile)
      end

    end

    def load_text!(p, klass)
      unless File.directory?(p)
        asset = klass.where(custom_theme_id: @custom_theme.id, name: File.basename(p)).first_or_initialize
        asset.body = File.read(p)
        asset.file = File.open(p)
        asset.save!
      end
    end

    def load_asset!(p, klass)
      unless File.directory?(p)
        asset = klass.where(custom_theme_id: @custom_theme.id, name: File.basename(p)).first_or_initialize
        asset.file = File.open(p)
        asset.save!
      end
    end

  end

end
