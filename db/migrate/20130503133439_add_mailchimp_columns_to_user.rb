class AddMailchimpColumnsToUser < ActiveRecord::Migration
  def up
    add_column :users, :mailchimp_synchronized_at, :timestamp
    add_column :users, :verified, :boolean, :default => false

    # script has been run in different environment, so we need to populate new column
    # for all users that were affected
    connection.execute <<-SQL
      UPDATE users 
      SET mailchimp_synchronized_at = '2013-05-08 12:38:25.099763'
      WHERE id <= 2575
    SQL
  end

  def down
    remove_column :users, :mailchimp_synchronized_at
    remove_column :users, :verified
  end
end
