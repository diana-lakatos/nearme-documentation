class PagesController < ApplicationController

  before_filter :page_prepend_view_path

  layout :resolve_layout

  def show
    @page = begin
              current_theme.pages.find_by_path!(params[:path]) 
            rescue ActiveRecord::RecordNotFound => e
              raise e unless Theme::DEFAULT_THEME_PAGES.include?(params[:path])
            end

    render :show, theme: current_theme, page_path: params[:path]
  end


  private

  def page_prepend_view_path
    lookup_context.class.register_detail(:theme) { nil }
    lookup_context.class.register_detail(:page_path) { nil }
    prepend_view_path PageResolver.instance
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

