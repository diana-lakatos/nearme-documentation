class PagesController < ApplicationController

  layout :resolve_layout

  def host_signup
  end

  def host_signup_2
  end

  def host_signup_3
  end

  def show
    @page = current_instance.pages.find_by_path!(params[:path])
  end

  private

  # Layout per action
  def resolve_layout
    case action_name
    when "host_signup"
      "landing"
    when "legal", "show"
      "application"
    else
      false
    end
  end
end

