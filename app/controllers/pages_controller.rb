class PagesController < ApplicationController

  before_filter :page_prepend_view_path

  layout :resolve_layout

  def show
    @page = begin
              current_theme.pages.find_by_path!(params[:path]) 
            rescue ActiveRecord::RecordNotFound => e
              raise e unless Theme::DEFAULT_THEME_PAGES.include?(params[:path])
            end
  end


  private

  def page_prepend_view_path
    prepend_view_path PageResolver.new('app/views', nil, current_theme, params[:path])
  end

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

