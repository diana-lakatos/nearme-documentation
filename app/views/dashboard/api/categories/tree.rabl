collection @categories, :object_root => false
node(:data) { |category| category.translated_name }
node(:attr) do |category|
  { :id => category.id,
    :name => category.translated_name,
    :root => category.parent.root?,
    :class => @selected_categories.include?(category) ? 'jstree-checked' : 'jstree-unchecked'
  }
end
node(:state) { "closed" }