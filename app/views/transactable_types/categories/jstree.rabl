collection @categories, :object_root => false
node(:data) { |category| category.name }
node(:attr) do |category|
  { :id => category.id,
    :name => category.name,
    :root => category.parent_id.nil?.to_s,
    :class => @selected_categories.include?(category) ? 'jstree-checked' : 'jstree-unchecked'
  }
end
node(:state) { "closed" }