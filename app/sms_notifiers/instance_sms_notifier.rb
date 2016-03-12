class InstanceSmsNotifier < SmsNotifier
  prepend_view_path 'app/views'
  prepend_view_path InstanceViewResolver.instance

  def details_for_lookup
    {
      :instance_id => PlatformContext.current.try(:instance).try(:id),
      :i18n_locale => I18n.locale
    }
  end


end
