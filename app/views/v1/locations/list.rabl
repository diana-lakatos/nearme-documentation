collection @locations, :root => false, :object_root => false
  attributes :id, :name

child :listings, :root => "listings", :object_root => false do
  attributes :id, :name
end
