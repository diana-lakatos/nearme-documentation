class CategoryDrop < BaseDrop
  attr_reader :category

  delegate :id, :name, to: :category

  def initialize(category)
    @category = category
  end
end
