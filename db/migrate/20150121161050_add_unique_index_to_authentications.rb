class AddUniqueIndexToAuthentications < ActiveRecord::Migration
  def change

    # there are 2 authentications that break unique key - they were created in 2010 - let's delete one obsoleted record that prevents
    # us from creating necessary index
    reversible { |direction| direction.up { connection.execute('DELETE from authentications WHERE user_id = 146') } }

    add_index :authentications, [:instance_id, :provider, :user_id], unique: true, name: 'one_provider_type_per_user_index'
    add_index :authentications, [:instance_id, :uid, :provider], unique: true, where: '(deleted_at IS NULL)', name: 'one_active_provider_uid_pair_per_marketplace'

  end
end
