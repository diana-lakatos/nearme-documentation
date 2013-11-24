class PagesController < ApplicationController

  layout :resolve_layout

  def show
    @page = begin
              platform_context.theme.pages.find_by_slug!(params[:path]) 
            rescue ActiveRecord::RecordNotFound
              raise Page::NotFound
            end

    render :show, platform_context: [platform_context.decorate]
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
