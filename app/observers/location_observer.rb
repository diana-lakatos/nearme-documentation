class LocationObserver < ActiveRecord::Observer

  def before_update(location)
    location.build_address_components_if_necessary
  end

  def after_create(location)
    location.build_address_components
  end



end
