class Manage::BaseController < ApplicationController
  before_filter :set_section_name
  before_filter :authenticate_user!

  private

  def set_section_name
    @section_name = 'dashboard'
  end

  def locations_scope
    @locations_scope ||= begin
      if current_user.is_location_administrator?
        current_user.administered_locations.for_instance(platform_context.instance)
      else
        current_user.locations.for_instance(platform_context.instance)
      end
    end
  end
end
