# frozen_string_literal: true
module Graph
  class QueryResolver
    def self.find_query(name)
      (GraphQuery.find_by(name: name) || from_file(name)).query_string
    end

    def self.from_file(name)
      GraphQuery.new(
        name: name,
        query_string: File.read(File.join(Rails.root, 'app', 'graph', 'graph', 'queries', "#{name}.graphql"))
      )
    end
  end
end
