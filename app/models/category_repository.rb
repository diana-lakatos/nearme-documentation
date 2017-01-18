class CategoryRepository
  def self.paths(category_ids)
    lookup_table
      .select { |n, _| category_ids.include? n[:id] }
      .each_with_object({}) { |(node, *rest), acc| acc[rest.last[:name]] ||= []; acc[rest.last[:name]] << node[:name] }
  end

  def self.lookup_table
    @lookup_table ||= CategoryLookupTable.new.tap(&:prepare)
  end

  class CategoryLookupTable
    attr_reader :table

    def initialize
      @table = []
    end

    def select(&block)
      return unless block_given?

      @table.select(&block)
    end

    def prepare
      tree.each { |root| traverse(root, []) }
    end

    def tree
      @db ||= category_list
    end

    def traverse(current, parents)
      current[:children].each { |node| traverse node, [current, parents] }

      add current, parents
    end

    def add(*nodes)
      @table << nodes.flatten.map { |n| n.slice(:id, :name) }
    end

    def category_list
      Category
        .includes(:parent, children: { children: { children: :children } })
        .roots
        .map { |x| CategorySerializer.new(x).as_json }
    end
  end
end
