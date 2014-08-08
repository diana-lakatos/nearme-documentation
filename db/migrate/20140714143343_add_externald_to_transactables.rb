class AddExternaldToTransactables < ActiveRecord::Migration

  class Transactable < ActiveRecord::Base
  end

  def change
    add_column :transactables, :external_id, :string

    Transactable.find_each do |t|
      if t.respond_to?(:external_id)
        t.send(:write_attribute, :external_id, t.external_id)
        t.save(validate: false)
      end
    end
    add_index :transactables, :external_id
  end

end
