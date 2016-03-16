# Class is skipping ApplicationController in inheritance tree to avoid unsetting all of the filters
class DynamicThemesController < ActionController::Base

  caches_action :show

  layout false

  before_action :set_cors_headers

  def show
    @theme = Theme.find(params[:theme_id])
    @stylesheet =  params[:stylesheet]

    expires_in 1.year, public: true
    fresh_when(@theme, public: true)
  end

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Request-Method'] = '*'

    response.headers['x-frame-options'] = nil
    response.headers['X-Content-Type-Options'] = nil
    request.session_options[:skip] = true
  end
end
