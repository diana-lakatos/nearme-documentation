class DynamicThemesController < ApplicationController

  caches_action :show
  skip_filter :apply_persisted_mixpanel_attributes
  skip_filter :set_locale

  def show
    @theme = Theme.find(params[:theme_id])
    stylesheet =  params[:stylesheet]

    # Remove session cookies from response
    base_date = @theme.updated_at
    expire_date = base_date + 1.year

    request.session_options[:skip] = true

    expires_in 1.year, :public => true

    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Request-Method'] = '*'
    response.headers['Expires'] = expire_date.httpdate
    response.headers['x-frame-options'] = nil
    response.headers['Last-Modified'] = expire_date.httpdate
    response.headers['Date'] = base_date.httpdate
    response.headers['Content-Type'] = 'text/css'
    response.headers['X-Content-Type-Options'] = nil

    render stylesheet.to_s, layout: false
  end
end
