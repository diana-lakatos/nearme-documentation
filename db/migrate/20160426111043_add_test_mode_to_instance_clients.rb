class AddTestModeToInstanceClients < ActiveRecord::Migration
  def change
    add_column :instance_clients, :test_mode, :boolean, default: true

    InstanceClient.all.each do |ic|
      ic.update_column :test_mode, begin ic.decorator.test_mode? rescue true; end
    end
  end
end
