class PagesController < ApplicationController

  layout :resolve_layout

  def show
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs([params[:slug], params[:slug2], params[:slug3]].compact.join('/'), params[:format]))
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs([params[:slug], params[:slug2]].compact.join('/'), params[:format])) if @page.nil?
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs(params[:slug], params[:format])) if @page.nil?
    raise Page::NotFound unless @page.present?

    assigns = {}
    assigns['params'] = params.except(*Rails.application.config.filter_parameters)
    assigns['current_user'] = current_user
    assigns['platform_context'] = PlatformContext.current.decorate
    if @page.redirect?
      redirect_to @page.redirect_url, status: @page.redirect_code
    elsif params[:simple]
      render :simple, platform_context: [platform_context.decorate]
    elsif @page.no_layout?
      render text: Liquid::Template.parse(@page.content).render(assigns, registers: { action_view: self }, filters: [LiquidFilters])
    else
      render :show, platform_context: [platform_context.decorate]
    end
  end

  def redirect
    redirect_to pages_path(params[:slug]), status: 301
  end

  private

  # Layout per action
  def resolve_layout
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
