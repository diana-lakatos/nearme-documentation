module Elastic
  module Aggregations
    module Nodes
      def self.create_field(type)
        case type
        when :nested then Nested
        when :terms  then Terms
        else
          BasicNode
        end
      end

      class Node
        def initialize(attributes = {})
          attributes.each do |name, value|
            instance_variable_set("@#{name}", value)

            unless respond_to? name
              self.class.send :define_method, name, -> { instance_variable_get "@#{name}" }
            end
          end

          yield(self) if block_given?
        end

        def add_field(field)
          aggregations.merge! node(field.body)
        end

        def add(type, attributes, &block)
          add_field Nodes.create_field(type).new(attributes, &block)
        end

        def to_h
          body.to_h
        end

        private

        def aggregations
          @aggregations ||= {}
        end

        def node(attributes)
          attributes.reject { |key, value| Array(value).empty? }
        end

        def body
          { label => aggregations }
        end
      end
    end
  end
end
