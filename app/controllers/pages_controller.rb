class PagesController < ApplicationController

  prepend_view_path PageResolver.instance
  before_filter :register_page_path_as_lookup_context_detail

  layout :resolve_layout

  def show
    @page = begin
              current_theme.pages.find_by_slug!(params[:path]) 
            rescue ActiveRecord::RecordNotFound => e
              raise e unless Theme::DEFAULT_THEME_PAGES.include?(params[:path])
            end

    render :show, theme: current_theme, page_path: params[:path]
  end


  private

  def register_page_path_as_lookup_context_detail
    register_lookup_context_detail(:page_path)
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

