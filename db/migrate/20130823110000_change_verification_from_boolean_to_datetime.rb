class ChangeVerificationFromBooleanToDatetime < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    add_column :users, :verified_at, :datetime, :default => nil
    User.where(:verified => true).update_all(verified_at: Time.zone.now)
    remove_column :users, :verified
  end

  def down
    add_column :users, :verified, :boolean, :default => false
    User.where('users.verified_at is not null').update_all(verified: true)
    remove_column :users, :verified_at
  end
end
