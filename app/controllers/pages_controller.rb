
class PagesController < ApplicationController

	layout :resolve_layout

	def privacy
	end

	def host_signup
	end

  def host_signup_2
  end

  private

  # Layout per action
  def resolve_layout
    case action_name
    when "privacy"
      "new_layout"
    else
      false
    end
  end

end
