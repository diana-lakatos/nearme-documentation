object @category
attributes :id, :name, :pretty_name, :permalink, :parent_id, :category_id

node do |t|
  child t.children => :categories do
    attributes :id, :name, :pretty_name, :permalink, :parent_id, :category_id
  end
end