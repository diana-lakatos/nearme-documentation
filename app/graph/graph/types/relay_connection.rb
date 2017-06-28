
# frozen_string_literal: true
module Graph
  module Types
    class RelayConnection
      def self.build(type)
        connections = ::Thread.current[:graph_relay_connections] ||= {}
        connections[type] ||= build_type(type)
      end

      def self.build_type(type)
        type.define_connection do
          name "#{type.name}Connection"
          field :total_count do
            type types.Int
            resolve ->(obj, _args, _ctx) { obj.nodes.count }
          end
        end
      end
    end
  end
end
