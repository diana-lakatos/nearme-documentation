class CopyContactToSupportEmail < ActiveRecord::Migration
  def up
    connection.execute <<-SQL
      UPDATE themes
      SET
        support_email = contact_email
      WHERE support_email IS NULL or support_email LIKE ''
    SQL
  end

  def down
  end
end
