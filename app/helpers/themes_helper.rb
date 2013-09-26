module ThemesHelper
  def theme_stylesheet_url(theme)
    if theme
      theme.compiled_stylesheet.url
    end || 'application'
  end
end
