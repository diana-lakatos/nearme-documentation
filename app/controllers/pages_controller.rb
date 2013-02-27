
class PagesController < ApplicationController

	layout :resolve_layout


	def host_signup
	end

  def host_signup_2
  end

  def host_signup_3
  end

  private

  # Layout per action
  def resolve_layout
    case action_name
    when "host_signup"
      "landing"
    when "legal"
      "application"
    when "w_hotels"
      "application"      
    else
      false
    end
  end

end
