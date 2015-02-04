class InstanceSmsNotifier < SmsNotifier
  prepend_view_path InstanceViewResolver.instance

  def details_for_lookup
    {
      :instance_type_id => PlatformContext.current.try(:instance_type).try(:id),
      :instance_id => PlatformContext.current.try(:instance).try(:id)
    }
  end


end
