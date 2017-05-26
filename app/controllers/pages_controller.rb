# frozen_string_literal: true
class PagesController < ApplicationController
  layout :resolve_layout
  respond_to :html

  skip_before_action :redirect_unverified_user, unless: -> { page.require_verified_user? }

  def show
    RenderCustomPage.new(controller: self, page: page, params: params).render
  end

  def redirect
    redirect_to pages_path(params[:slug]), status: 301
  end

  private

  def page
    @page ||= find_page
  end

  def find_page
    Pages::PageQuery.new(
      slug: params[:slug],
      slug2: params[:slug2],
      slug3: params[:slug3],
      format: params[:format],
      relation: platform_context.theme.pages
    ).find
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
