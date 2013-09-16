module ThemesHelper
  def theme_stylesheet_url(theme_owner = current_domain.target)
    if theme_owner.theme
      theme_owner.theme.compiled_stylesheet.url
    end || 'application'
  end
end
