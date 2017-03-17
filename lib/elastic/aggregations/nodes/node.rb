# frozen_string_literal: true
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
        delegate :to_h, to: :body

        def initialize(attributes = {})
          attributes.each do |name, value|
            instance_variable_set("@#{name}", value)

            self.class.send :define_method, name, -> { instance_variable_get "@#{name}" } unless respond_to? name
          end

          yield(self) if block_given?
        end

        def add_field(field)
          aggregations.merge! node(field.body)
        end

        def add(type, attributes, &block)
          add_field Nodes.create_field(type).new(attributes, &block)
        end

        private

        def aggregations
          @aggregations ||= {}
        end

        def node(attributes)
          attributes.reject { |_key, value| Array(value).empty? }
        end

        def body
          { label => aggregations }
        end
      end
    end
  end
end
