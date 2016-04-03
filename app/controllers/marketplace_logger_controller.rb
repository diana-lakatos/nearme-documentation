class MarketplaceLoggerController < ApplicationController

  JAVASCRIPT_ERROR = 'Javascript Error'

  def create
    MarketplaceLogger.error(JAVASCRIPT_ERROR, params[:message], raise: false, url: params[:url])
    render nothing: true
  end
end
