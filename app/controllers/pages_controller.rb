# frozen_string_literal: true
class PagesController < ApplicationController
  layout :resolve_layout
  respond_to :html

  def show
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs([params[:slug], params[:slug2], params[:slug3]].compact.join('/'), params[:format]))
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs([params[:slug], params[:slug2]].compact.join('/'), params[:format])) if @page.nil?
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs(params[:slug], params[:format])) if @page.nil?
    raise Page::NotFound unless @page.present?
    RenderCustomPage.new(self).render(page: @page, params: params)
  end

  def redirect
    redirect_to pages_path(params[:slug]), status: 301
  end

  private

  # Layout per action
  def resolve_layout
    case action_name
    when 'host_signup'
      'landing'
    when 'show'
      layout_name
    else
      false
    end
  end
end
