class Manage::BaseController < ApplicationController
  before_filter :set_section_name
  before_filter :authenticate_user!
  before_filter :force_scope_to_instance

  private

  def set_section_name
    @section_name = 'dashboard'
  end

  def locations_scope
    @locations_scope ||= begin
      if current_user.is_location_administrator?
        current_user.administered_locations
      else
        current_user.locations
      end
    end
  end
end
