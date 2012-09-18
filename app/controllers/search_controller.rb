require "will_paginate/array"
class SearchController < ApplicationController

  def index
    if @search = find_search_query
      @listings = Listing.find_by_search_params(@search).select(&:strict_match).reject { |l| l.location.nil? } # tmp hax
      @listings = @listings.paginate(:page => params[:page], :per_page => 20)

      @query = @search[:pretty] || @search[:query]
      SearchQuery.create(:query => @search[:query], :agent => request.env['HTTP_USER_AGENT'])
    end

    if request.xhr?
      render :partial => "search/listings.html", :layout => false
    else
      render
    end
  end

  private

    def find_search_query
      query = params[:q] || params[:address]
      lat = params[:lat]
      lng = params[:lng]
      query = if query && !lat && !lng
        extract_search_from_geocoding(query)
      elsif query && lat && lng
        extract_search_from_params(query, lat.to_f, lng.to_f)
      end

      if params[:availability].present?
        query[:availability] = {}

        if params[:availability][:quantity].present?
          query[:availability][:quantity] = {
            :min => params[:availability][:quantity].try(:to_i)
          }
        end

        if params[:availability][:dates].present?
          param = params[:availability][:dates]

          query[:availability][:dates] = {} if param[:start].present? || param[:end].present?
          query[:availability][:dates][:start] = Date.parse(param[:start]) if param[:start].present?
          query[:availability][:dates][:end]   = Date.parse(param[:end]) if param[:end].present?
        end
      end

      if params[:price].present? && (params[:price][:min].present? && params[:price][:max].present?)
        query[:price] = {
          :min => params[:price][:min].to_i,
          :max => params[:price][:max].to_i
        }
      end

      if params[:amenities].present?
        query[:amenities] = params[:amenities].map(&:to_i)
      end

      if params[:organizations].present?
        query[:organizations] = params[:organizations].map(&:to_i)
      end

      query
    end

    def extract_search_from_geocoding(query)
      search = { :query => query }
      geocoded = Geocoder.search(query).try(:first)
      return search if geocoded.nil?

      loc = geocoded.data
      geometry = loc['geometry']

      search[:pretty] = loc['formatted_address']
      search[:midpoint] = [geometry['location']['lat'], geometry['location']['lng']]

      bounds = geometry['bounds']
      if bounds && (loc['types'] == ["country","political"]) || (loc['types'] == ["administrative_area_level_1","political"])
        search[:boundingbox] = {
          :start => {
            :lat => bounds['northeast']['lat'].to_f,
            :lon => bounds['northeast']['lon'].to_f
          },
          :end => {
            :lat => bounds['southwest']['lat'].to_f,
            :lon => bounds['southwest']['lon'].to_f
          }
        }
      end

      search
    end

    def extract_search_from_params(query, lat, lng)
      search = { :query => query, :lat => lat, :lng => lng }

      search[:midpoint] = [lat, lng]

      if params[:nx] && params[:ny] && params[:sx] && params[:sy]
        search[:boundingbox] = {
          :start => {
            :lat => params[:nx].to_f,
            :lon => params[:ny].to_f
          },
          :end => {
            :lat => params[:sx].to_f,
            :lon => params[:xy].to_f
          }
        }
      end

      search
    end

end
