class CategoryTreeInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    category = options[:category]

    input_html_options['data-category-id'] = category.id
    input_html_options['data-category-api-url'] = Rails.application.routes.url_helpers.tree_new_ui_dashboard_api_category_path(category.id)
    input_html_options['data-category-multiple-choice'] = category.multiple_root_categories
    input_html_options['data-value'] = object.common_categories(category).map(&:id).join(',')

    template.content_tag :div, class: 'form-category-tree', data: { "category-tree-input": true } do
      super(wrapper_options)
    end
  end
end
