class CategoryDrop < BaseDrop
  attr_reader :category

  # id
  #   id of category as integer
  # name
  #   name of category as string
  delegate :id, :name, to: :category

  def initialize(category)
    @category = category
  end
end
