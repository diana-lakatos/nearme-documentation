class Manage::BaseController < ApplicationController
  before_filter :set_section_name
  before_filter :authenticate_user!

  private

  def set_section_name
    @section_name = 'dashboard'
  end

  def set_locations_scope
    if current_user.is_location_administrator? 
      @locations_scope = current_user.administered_locations
    else
      @locations_scope = current_user.locations
    end
  end

end
