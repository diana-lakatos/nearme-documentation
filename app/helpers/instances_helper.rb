module InstancesHelper
  def instance_theme_stylesheet_url(instance = current_instance)
    if instance.theme
      instance.theme.compiled_stylesheet.try(:url)
    end || 'application'
  end
end
