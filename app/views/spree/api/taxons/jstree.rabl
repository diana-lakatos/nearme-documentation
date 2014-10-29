collection @taxon.children, :object_root => false
node(:data) { |taxon| taxon.name_with_top_nav_position }
node(:attr) do |taxon|
  { :id => taxon.id,
    :name => taxon.name,
    :in_top_nav => taxon.in_top_nav,
    :top_nav_position => taxon.top_nav_position
  }
end
node(:state) { "closed" }
