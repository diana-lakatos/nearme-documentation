# frozen_string_literal: true
# Class is skipping ApplicationController in inheritance tree to avoid unsetting all of the filters
class DynamicThemesController < ActionController::Base
  layout false

  before_action :set_cors_headers

  def show
    @theme = Theme.find(params[:theme_id])
    @stylesheet = params[:stylesheet]

    expires_in 1.year, public: true
    fresh_when(@theme, public: true, template: "dynamic_themes/#{@stylesheet}") || render(@stylesheet.to_s)
  end

  private

  def set_cors_headers
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Request-Method'] = '*'

    remove_keys = %w(X-Frame-Options X-Content-Type-Options)
    response.headers.delete_if { |key| remove_keys.include? key }

    request.session_options[:skip] = true
  end

  def user_for_paper_trail
    nil # disable whodunnit tracking for papertrail
  end
end
