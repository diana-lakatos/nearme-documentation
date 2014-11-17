object false
node(:data) { @taxonomy.root.name_with_top_nav_position }
node(:attr) do
  { :id => @taxonomy.root.id,
    :name => @taxonomy.root.name,
    :in_top_nav => @taxonomy.root.in_top_nav,
    :top_nav_position => @taxonomy.root.top_nav_position
  }
end
node(:state) { "closed" }
