class AddParentToAvailabilityTemplate < ActiveRecord::Migration
  def change
    add_reference :availability_templates, :parent, polymorphic: true, index: true
  end
end
