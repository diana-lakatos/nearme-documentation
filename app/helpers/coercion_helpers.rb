module CoercionHelpers
  def coerce_pagination_params params
    SearchPaginationParams.coerce params
  end

  module Controller
    def coerce_pagination_params
      SearchPaginationParams.coerce params
    end
  end

  class SearchPaginationParams
    def self.coerce(params)
      params[:page]     = to_positive_integer params[:page], 1
      params[:per_page] = to_positive_integer params[:per_page], 20
      params
    end

    def self.to_positive_integer(value, default)
      number = value.to_i rescue default

      number < 1 ? default : number
    end
  end
end
