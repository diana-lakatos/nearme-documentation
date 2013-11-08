class AddLessorLesseeToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :lessor, :string
    add_column :instances, :lessee, :string

    Instance.update_all(lessor: 'host')
    Instance.update_all(lessee: 'guest')
  end
end
