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

    def self.to_positive_integer(param, default)
      Integer(param).tap { |i_value| raise ArgumentError unless i_value.positive? }
    rescue ArgumentError, TypeError
      default
    end
  end
end
