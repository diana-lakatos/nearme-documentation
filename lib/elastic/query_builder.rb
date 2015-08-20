module Elastic
  class QueryBuilder

    QUERY_BOOST = 1.0
    ENABLE_FUZZY = false
    ENABLE_PARTIAL = false
    FUZZYNESS = 2
    ANALYZER = 'snowball'
    GEO_DISTANCE = 'plane'
    GEO_UNIT = 'km'
    GEO_ORDER = 'asc'
    MAX_RESULTS = 1000

    def initialize(query, searchable_custom_attributes)
      @query = query
      @bounding_box = query[:bounding_box]
      @searchable_custom_attributes = searchable_custom_attributes
      @filters = []
      @not_filters = []
    end

    def query_limit
      @query[:limit] || MAX_RESULTS
    end

    def product_query
      @filters = initial_product_filters
      apply_product_search_filters
      {
        size: query_limit,
        sort: ['_score'],
        query: products_match_query,
        filter: {
          bool: {
            must: @filters
          }
        }
      }
    end

    def geo_regular_query
      @filters = initial_service_filters
      apply_geo_search_filters
      {
        size: query_limit,
        sort: ['_score'],
        query: match_query,
        filter: {
          bool: {
            must: @filters
          }
        }
      }
    end

    def geo_query
      @filters = initial_service_filters + geo_filters
      apply_geo_search_filters
      {
        size: query_limit,
        query: {
          filtered: {
            query: match_query,
            filter: {
              not: {
                filter: {
                  bool:{
                    must: @not_filters
                  }
                }
              }
            }
          }
        },
        sort: geo_sort,
        filter: {
          bool: {
            must: @filters
          }
        }
      }
    end

    def initial_service_filters
      searchable_service_type_ids = [@query[:transactable_type_id].to_i] & TransactableType.where(searchable: true).map(&:id)
      searchable_service_type_ids = [0] if searchable_service_type_ids.empty?
      [
      	initial_instance_filter,
        {
          term: {
            transactable_type_id: searchable_service_type_ids
          }
        }
      ]
    end

    def initial_instance_filter
      {
        term: {
          instance_id: @query[:instance_id]
        }
      }
    end

    def initial_product_filters
      product_type_id = @query[:product_type_id].to_i
      searchable_product_types = Spree::ProductType.where(searchable: true).map(&:id)
      searchable_product_type_ids = if product_type_id
        [product_type_id] & searchable_product_types
      else
        searchable_product_types = [0] if searchable_product_types.empty?
        searchable_product_types
      end
      [
        initial_instance_filter,
        {
          terms: {
            product_type_id: searchable_product_type_ids
          }
        }
      ]
    end

    def geo_filters
      if @bounding_box
        [
          {
            geo_bounding_box: {
              geo_location: {
                top_left: {
                  lat: @bounding_box.first.first.to_f, 
                  lon: @bounding_box.last.last.to_f
                },
                bottom_right: {
                  lat: @bounding_box.last.first.to_f,
                  lon: @bounding_box.first.last.to_f
                }
              }
            }
          }
        ]
      else
        [
          {
            geo_distance: {
              distance: @query[:distance],
              geo_location: {
                lat: @query[:lat],
                lon: @query[:lon]
              }
            }
          }
        ]
      end
    end

    def geo_sort
      [
        {
          _geo_distance: {
            geo_location: {
              lat: @query[:lat],
              lon: @query[:lon]
            },
            order:         GEO_ORDER,
            unit:          GEO_UNIT,
            distance_type: GEO_DISTANCE
          }
        }
      ]
    end

    def match_query
      if @query[:query].blank?
        { match_all: { boost: QUERY_BOOST } }
      else
        query = BaseIndex.sanitize_string(@query[:name])
        { multi_match: build_multi_match(query, @searchable_custom_attributes + ['name^20', 'description']) }
      end
    end

    def build_multi_match(query_string, custom_attributes)
      multi_match = {
        query: query_string,
        fields: custom_attributes
      }

      # You should enable fuzzy search manually. Not included in the current release
      if ENABLE_FUZZY
        multi_match.merge!({
          fuzziness: FUZZYNESS,
          analyzer: ANALYZER
        })
      end

      multi_match
    end

    def products_match_query
      if @query[:name].blank?
        { match_all: { boost: QUERY_BOOST } }
      else
        query = BaseIndex.sanitize_string(@query[:name])
        { multi_match: build_multi_match(query, @searchable_custom_attributes + ['name^20', 'description']) }
      end
    end

    def apply_product_search_filters
      category_search_type = PlatformContext.current.instance.category_search_type

      if @query[:category_ids] && @query[:category_ids].any?
        if category_search_type == 'OR'
          @filters << {
            terms: {
              categories: @query[:category_ids].map(&:to_i)
            }
          }
        elsif category_search_type == 'AND'
          @query[:category_ids].each do |category|
            @filters << {
              terms: {
                categories: [category.to_i]
              }
            }
          end
        end
      end
    end

    def apply_geo_search_filters
      if @query[:location_types_ids] && @query[:location_types_ids].any?
        @filters << {
          terms: {
            location_type_id: @query[:location_types_ids].map(&:id)
          }
        }
      end

      @filters << { 
        term: {
          enabled: true
        }
      }

      if @query[:lg_custom_attributes]
        @query[:lg_custom_attributes].each do |key, value|
          unless value.blank?
            @filters << {
              terms: {
                "custom_attributes.#{key}" => value.to_s.downcase.scan(/\w+/).map(&:strip).map(&:downcase)
              }
            }
          end
        end
      end
  
      category_search_type = PlatformContext.current.instance.category_search_type

      if @query[:category_ids] && @query[:category_ids].any?
        if category_search_type == 'OR'
          @filters << {
            terms: {
              categories: @query[:category_ids].map(&:to_i)
            }
          }
        elsif category_search_type == 'AND'
          @query[:category_ids].each do |category|
            @filters << {
              terms: {
                categories: [category.to_i]
              }
            }
          end
        end
      end

      if @query[:listing_pricing] && @query[:listing_pricing].any?
        @query[:listing_pricing].each do |lp|
          @not_filters << {
            term: {
              "#{lp}_price_cents" => 0
            }
          }
        end
      end
    end

  end
end