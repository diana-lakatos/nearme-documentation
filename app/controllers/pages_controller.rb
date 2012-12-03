
class PagesController < ApplicationController

	layout :resolve_layout

	def privacy
	end

	def host_signup
	end

  private

  # Layout per action
  def resolve_layout
    case action_name
    when "host_signup"
      "landing"
    else
      "new_layout"
    end
  end

end
