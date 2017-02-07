if defined?(WillPaginate)
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        def per(value = nil)
          limit(value.nil? ? limit_value : value)
        end

        def total_count
          count
        end
      end
    end
    module CollectionMethods
      alias_method :num_pages, :total_pages

      # First page of the collection?
      def first_page?
        current_page == 1
      end

      # Last page of the collection?
      def last_page?
        current_page >= total_pages
      end
    end
    module ActionView
      def will_paginate(collection = nil, options = {}) #:nodoc:
        # options, collection = collection, nil if collection.is_a? Hash
        collection ||= infer_collection_from_controller

        options = options.symbolize_keys
        options[:renderer] ||= LinkRenderer

        super(collection, options)
      end
    end
  end
end
