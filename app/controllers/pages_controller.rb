# frozen_string_literal: true
class PagesController < ApplicationController
  layout :resolve_layout
  respond_to :html

  skip_before_action :redirect_unverified_user, unless: -> { page.require_verified_user? }

  def show
    RenderCustomPage.new(self).render(page: page, params: params)
  end

  def redirect
    redirect_to pages_path(params[:slug]), status: 301
  end

  private

  def page
    return @page if @page

    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs([params[:slug], params[:slug2], params[:slug3]].compact.join('/'), params[:format]))
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs([params[:slug], params[:slug2]].compact.join('/'), params[:format])) if @page.nil?
    @page = platform_context.theme.pages.find_by(slug: Page.possible_slugs(params[:slug], params[:format])) if @page.nil?

    raise Page::NotFound unless @page.present?

    @page
  end

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

  def set_new_relic_transaction_name
    NewRelic::Agent.set_transaction_name(
      "#{PlatformContext.current.instance.id} - #{page.slug}"
    )
  end
end
