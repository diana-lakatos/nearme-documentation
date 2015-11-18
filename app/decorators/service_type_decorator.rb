class ServiceTypeDecorator < TransactableTypeDecorator
  include Draper::LazyHelpers

  delegate_all

  def display_location_type_filter?
    search_location_type_filter && PlatformContext.current.instance.location_types.count > 1
  end

end