class CategoryRepository
  def self.paths(category_ids)
    category_list(category_ids)
  end

  def self.category_list(category_ids)
    Category
      .where(id: category_ids)
      .order(:permalink)
      .pluck(:permalink, :name)
      .map { |permalink, name| NodeCategory.new(permalink, name) }
      .each_with_object(CategoryTree.new) { |category, output| output.add(category) }
  end

  class CategoryTree
    def initialize
      @tree = Hash.new
    end

    def add(category)
      @tree[category.root] ||= []
      @tree[category.root] << category.name
    end

    def [](key)
      @tree[key]
    end

    def to_liquid
      @tree.to_liquid
    end
  end

  class NodeCategory
    attr_reader :name

    def initialize(permalink, name)
      @permalink = permalink
      @name = name
    end

    def root
      body.first
    end

    private

    def body
      @permalink.split('/')
    end
  end
end
