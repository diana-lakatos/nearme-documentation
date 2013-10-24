class PagesController < ApplicationController

  layout :resolve_layout

  def show
    @page = platform_context.instance.pages.find_by_path!(params[:path])
  end

  private

  # Layout per action
  def resolve_layout
    case action_name
    when "host_signup"
      "landing"
    when "show"
      "application"
    else
      false
    end
  end
end

