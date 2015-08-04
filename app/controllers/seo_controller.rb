class SeoController < ApplicationController
  def sitemap
    @sitemap = platform_context.domain.sitemap
    respond_to do |format|
      format.xml { render xml: @sitemap }
    end
  end

  def robots
    @robots = platform_context.domain.robots
    render text: @robots
  end
end
