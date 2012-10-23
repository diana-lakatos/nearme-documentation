class Listing::SearchParams

  attr_accessor :form_params, :search_params, :location_string

  def initialize(params)
    @form_params = params
    @search_params = {}
    @location_string = form_params[:q] || form_params[:address]
    @found_location = false
    build_search_params
  end

  def parsed_params
    search_params.merge :query => location_string
  end

  def lat
    (search_params[:lat] || form_params[:lat])
  end

  def lng
    (search_params[:lng] || form_params[:lng])
  end

  def found_location?
    @found_location
  end

  private
    def build_search_params
      if location_string && !lat && !lng
        extract_search_from_geocoding
      elsif location_string && lat && lng
        extract_search_from_params
      end

      if form_params[:availability].present?
        search_params[:availability] = {}

        if form_params[:availability][:quantity].present?
          search_params[:availability][:quantity] = {
            :min => form_params[:availability][:quantity].try(:to_i)
          }
        end

        if form_params[:availability][:dates].present?
          param = form_params[:availability][:dates]

          search_params[:availability][:dates] = {} if param[:start].present? || param[:end].present?
          search_params[:availability][:dates][:start] = Date.parse(param[:start]) if param[:start].present?
          search_params[:availability][:dates][:end]   = Date.parse(param[:end]) if param[:end].present?
        end
      end

      if form_params[:price].present? && (form_params[:price][:min].present? && form_params[:price][:max].present?)
        search_params[:price] = {
          :min => form_params[:price][:min].to_i,
          :max => form_params[:price][:max].to_i
        }
      end

      if form_params[:amenities].present?
        search_params[:amenities] = form_params[:amenities].map(&:to_i)
      end

      if form_params[:organizations].present?
        search_params[:organizations] = form_params[:organizations].map(&:to_i)
      end
    end

    def extract_search_from_geocoding
      geocoded = Geocoder.search(location_string).try(:first)
      return if geocoded.nil?

      @found_location = true;
      loc = geocoded.data
      geometry = loc['geometry']

      search_params[:pretty] = loc['formatted_address']
      search_params[:midpoint] = [geometry['location']['lat'], geometry['location']['lng']]

      bounds = geometry['bounds']
      if bounds && (loc['types'] == ["country","political"]) || (loc['types'] == ["administrative_area_level_1","political"])
        search_params[:boundingbox] = {
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
    end

    def extract_search_from_params
      search_params[:midpoint] = [lat, lng]

      if form_params[:nx] && form_params[:ny] && form_params[:sx] && form_params[:sy]
        search_params[:boundingbox] = {
          :start => {
            :lat => form_params[:nx].to_f,
            :lon => form_params[:ny].to_f
          },
          :end => {
            :lat => form_params[:sx].to_f,
            :lon => form_params[:xy].to_f
          }
        }
      end
    end
end
