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
    return @page if @page
    3.downto(1).each do |level|
      @page = platform_context.theme.pages.find_by(slug: slug_varations(possible_slugs_x_level_deep(level)))
      break if @page.present?
    end
    validate_slugs!
    @page
  end

  def validate_slugs!
    raise Page::NotFound unless @page.present?
    raise Page::NotFound if @page.max_deep_level < 2 && params[:slug2].present?
    raise Page::NotFound if @page.max_deep_level < 3 && params[:slug3].present?
  end

  def possible_slugs_x_level_deep(deep_level = 1)
    case deep_level
    when 3
      [params[:slug], params[:slug2], params[:slug3]]
    when 2
      [params[:slug], params[:slug2]]
    else
      [params[:slug]]
    end.compact.join('/')
  end

  def slug_varations(slug)
    Page.possible_slugs(slug, params[:format])
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
