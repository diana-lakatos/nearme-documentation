require "will_paginate/array"
class SearchController < ApplicationController

  SEARCH_PARAMS = %w(q lat lng ny nx sy sx)

  before_filter :store_or_retreive_params_from_session, :only => [:index]

  def index

    @search = Listing::Search::Params::Web.new(params)

    @listings = Listing.find_by_search_params(@search).reject { |l| l.location.nil? } # tmp hax
    @query = @search.location_string

    SearchQuery.create(:query => @search.location_string, :agent => request.env['HTTP_USER_AGENT'])

    if request.xhr?
      render :partial => "search/listings", :layout => false
    else
      render
    end
  end

  private

  def store_or_retreive_params_from_session
    params[:q] ? remember_last_search : reapply_remembered_search
  end

  def remember_last_search
    session[:last_search_params] = {}
    SEARCH_PARAMS.each do |param|
      session[:last_search_params][param] = params[param]
    end
  end

  def reapply_remembered_search
    return unless session[:last_search_params].present?
    SEARCH_PARAMS.each do |param|
      params[param] = session[:last_search_params][param]
    end
  end

end
