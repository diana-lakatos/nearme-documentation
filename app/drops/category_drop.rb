class CategoryDrop < BaseDrop
  # @return [CategoryDrop]
  attr_reader :category

  # @!method id
  #   id of category as integer
  #   @return [Integer] 
  # @!method name
  #   the name of the category
  #   @return (see Category#name)
  # @!method children
  #   @return [Array<CategoryDrop>] collection of subcategories
  delegate :id, :name, :children, to: :category

  def initialize(category)
    @category = category
  end

  # @return [Array<CategoryDrop>] array of descendants sorted by name
  def sorted_descendants
    @category.descendants.sort { |a, b| a.name.downcase <=> b.name.downcase }
  end
end
