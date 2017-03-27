class CategoryHashSerializer

  def initialize(category, selected_categories)
    @category = category
    @selected_categories = selected_categories
  end

  def to_json
    build_category(@category)
  end

  private
  
  def build_category(category)
    # Path of IDs, used for fast lookup
    path = [category.id]
    built_category = build_category_hash(category)
    # Path of actual constructed objects
    built_path = [built_category]

    # These will be correctly ordered by lft
    category.descendants.each do |o|
      if o.parent_id != path.last
        # We are on a new level, did we descend or ascend?
        if path.include?(o.parent_id)
          # Remove the wrong trailing path elements
          while path.last != o.parent_id
            path.pop
            built_path.pop
          end
        else
          path << o.parent_id
          built_path << built_path.last[:children].last
        end
      end

      built_path.last[:children] << build_category_hash(o)
    end

    built_category
  end

  def build_category_hash(category)
    {
      id: category.id,
      text: category.translated_name,
      state: {
        opened: !category.leaf? && @selected_categories.include?(category),
        checked: @selected_categories.include?(category)
      },
      children: []
    }
  end

end
