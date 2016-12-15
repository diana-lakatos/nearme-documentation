# frozen_string_literal: true
class AddPrependViewPathToInstances < ActiveRecord::Migration
  def up
    add_column :instances, :prepend_view_path, :string, default: nil
    hash = {
      '132' => 'devmesh',
      '5011' => 'hallmark'
    }
    Instance.where(id: [132, 5011]).find_each do |i|
      i.update_attribute(:prepend_view_path, hash[i.id.to_s])
    end
  end

  def down
    remove_column :instances, :prepend_view_path
  end
end
