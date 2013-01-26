collection @locations, :root => false, :object_root => false
  attributes :id, :name, :description, :email, :phone

  child :listings, :child_root => false do
    attributes :id, :name, :description

end
