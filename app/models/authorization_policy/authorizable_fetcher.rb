# frozen_string_literal: true
class AuthorizationPolicy
  class AuthorizableFetcher
    def initialize(object_name:, object_type:)
      @object_name = object_name
      @object_type = object_type
    end

    def fetch
      FetcherFactory.new(object_type).fetcher.new(@object_name).fetch
    end

    class FetcherFactory
      def initialize(object_type)
        @object_type = object_type
      end

      def fetcher
        case @object_type
        when 'form_configuration'
          FormConfigurationFetcher
        when 'page'
          PageFetcher
        else
          raise NotImplementedError, "Invalid object type: #{@object_type}.\
Valid object_types: form_configuration, page"
        end
      end
    end

    class FormConfigurationFetcher
      def initialize(name)
        @name = name
      end

      def fetch
        FormConfiguration.find_by(name: object_name).tap do |fc|
          unless fc
            raise NotImplementedError, "Can't find form configuration with name: #{@name}.\
Valid names: #{FormConfiguration.pluck(:name)}"
          end
        end
      end
    end

    class PageFetcher
      def initialize(name)
        @name = name
      end

      def fetch
        Page.find_by(slug: object_name).tap do |page|
          unless page
            raise NotImplementedError, "Can't find page with slug: #{@name}.\
Valid slugs: #{Page.pluck(:slug)}"
          end
        end
      end
    end
  end
end
