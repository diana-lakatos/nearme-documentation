object @taxon
attributes :id, :name, :pretty_name, :permalink, :parent_id, :taxonomy_id

node do |t|
  child t.children => :taxons do
    attributes :id, :name, :pretty_name, :permalink, :parent_id, :taxonomy_id
  end
end