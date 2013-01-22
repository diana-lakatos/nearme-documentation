class LocationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create, :populate_address_components_form, :populate_address_components]
  expose :location

  def show
    @location = location
  end

  def populate_address_components_form
    # by default we will fetch only these locations, which have 0 address_component_names.
    @address_component_names = params["force"] ? [] : AddressComponentName.select("distinct location_id")
    @excluded_locations_id = @address_component_names.collect(&:location_id)
    @locations = Location.select("formatted_address, id").where("formatted_address is not null AND formatted_address <> '' #{" AND id NOT IN (#{@excluded_locations_id * ','})" unless @excluded_locations_id.empty?} ")
  end

  def populate_address_components
    counter = 0
    params["address_components"].each do |location_id, address_components|
      @location = Location.find(location_id)
      @location.address_components_hash = address_components
      @location.address_component_names.destroy_all
      @location.build_address_components
      counter += 1
    end if params["address_components"]
    render :text => "Done, added components for #{counter} locations."
  end

  # Return a summary in JSON for all listings availability over specified days
  #
  # Usage:
  #   GET /locations/id/availability_summary?dates[]=2012-11-13&dates[]=2012-11-14&dates[]=2012-11-15
  #
  # Response:
  #   [
  #     { id: "1", availability: {
  #       "2012-11-13" : { available: 10, total: 10 },
  #       "2012-11-14" : { available: 2, total: 10 },
  #       "2012-11-14" : { available: 0, total: 10 }
  #     },
  #     ...
  #   ]
  #
  def availability_summary
    dates = Array.wrap(params[:dates]).map { |date|
      begin
        Date.parse(date)
      rescue ArgumentError
        nil
      end
    }.compact

    render :json => location.listings.map { |listing|
      {
        :id => listing.id,
        :availability => Hash[
          dates.map { |date|
            [date.strftime("%Y-%m-%d"), { :available => listing.availability_for(date), :total => listing.quantity_for(date) }]
          }
        ]
      }
    }.to_json
  end
end
