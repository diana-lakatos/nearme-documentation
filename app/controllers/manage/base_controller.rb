class Manage::BaseController < ApplicationController
  before_filter :set_section_name

  private

  def set_section_name
    @section_name = 'dashboard'
  end

end
