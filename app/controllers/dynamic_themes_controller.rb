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
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Expires'] = expire_date.httpdate
    headers['x-frame-options'] = nil
    headers['Last-Modified'] = expire_date.httpdate
    headers['Date'] = base_date.httpdate
    headers['Content-Type'] = 'text/css'
    headers['X-Content-Type-Options'] = nil

    render stylesheet.to_s, layout: false
  end
end
