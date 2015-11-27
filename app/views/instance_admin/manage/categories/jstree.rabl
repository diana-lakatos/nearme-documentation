collection @categories, :object_root => false
node(:data) { |category| category.name }
node(:attr) do |category|
  { :id => category.id,
    :name => category.name,
    :is_root => category.root?
  }
end
node(:state) { "closed" }
