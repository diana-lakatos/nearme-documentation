module CategoriesHelper
  def build_categories_hash_for_object(object, root_categories)
    @object_permalinks = object.categories.pluck(:permalink)
    @root_categories = @object_permalinks.map { |p| p.split('/')[0] }.uniq
    categories = {}
    root_categories.find_each do |category|
      children = if @root_categories.include?(category.permalink)
                   category.children.map { |child| build_value_for_category(child) }.compact
                 else
                   []
                 end
      categories[category.name] = { 'name' => category.translated_name, 'children' => children }
    end
    categories
  end

  def build_categories_hash(root_categories)
    categories = {}
    root_categories.find_each do |category|
      children = category.children.map { |child| build_all_values_for_category(child) }.compact
      categories[category.name] = { 'name' => category.translated_name, 'children' => children }
    end
    categories
  end

  def build_formatted_categories(categories)
    if @formatted_categories.nil?
      @formatted_categories = {}
      parent_ids = categories.map(&:parent_id)
      categories.reject { |c| c.id.in?(parent_ids) }.map do |category|
        @formatted_categories[category.root.name] ||= { 'name' => category.root.translated_name, 'children' => [] }
        @formatted_categories[category.root.name]['children'] << sorted_self_and_ancestors(category).reject(&:root?).map(&:translated_name).join(': ')
      end
      @formatted_categories.each_pair { |parent, values| @formatted_categories[parent]['children'] = values['children'].join(', ') }
    end
    @formatted_categories
  end

  def build_categories_to_array(categories)
    if @formatted_categories.nil?
      @formatted_categories = {}
      parent_ids = categories.map(&:parent_id)
      categories.reject { |c| c.id.in?(parent_ids) }.map do |category|
        @formatted_categories[category.root.name] ||= { 'name' => category.root.translated_name, 'children' => [] }
        @formatted_categories[category.root.name]['children'] << sorted_self_and_ancestors(category).reject(&:root?).map(&:translated_name)
      end
      @formatted_categories.each_pair { |parent, values| @formatted_categories[parent]['children'].flatten! }
    end
    @formatted_categories
  end

  protected

  def sorted_self_and_ancestors(start_category)
    categories = []
    current_category = start_category
    while current_category.present? do
      categories.prepend(current_category)
      current_category = current_category.parent
    end
    categories
  end

  def build_value_for_category(category)
    if @object_permalinks.include?(category.permalink)
      if category.leaf?
        category.translated_name
      else
        { category.translated_name => category.children.map { |child| build_value_for_category(child) }.compact }
      end
    end
  end

  def build_all_values_for_category(category)
    if category.leaf?
      category.translated_name
    else
      { category.translated_name => category.children.map { |child| build_all_values_for_category(child) }.compact }
    end
  end
end
