class PagesController < ApplicationController

  layout :resolve_layout

  def show
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs(params[:slug], params[:format]))
    raise Page::NotFound unless @page.present?

    if @page.redirect?
      redirect_to @page.redirect_url, status: @page.redirect_code
    else
      render :show, platform_context: [platform_context.decorate]
    end
  end

  def redirect
    redirect_to pages_path(params[:slug])
  end

  private

  # Layout per action
  def resolve_layout
    return false if @page.no_layout?

    case action_name
    when "host_signup"
      "landing"
    when "show"
      layout_name
    else
      false
    end
  end
end
