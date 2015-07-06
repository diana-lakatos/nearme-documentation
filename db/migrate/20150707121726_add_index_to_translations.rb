class AddIndexToTranslations < ActiveRecord::Migration
  def change
    # Deleting duplicate keys where value is blank
    connection.execute <<-SQL
      DELETE FROM translations t1 
      WHERE EXISTS
        (SELECT 1 FROM translations t2
          WHERE t1.instance_id = t2.instance_id AND t1.locale = t2.locale
          AND t1.key = t2.key AND t1.id != t2.id AND t1.value = ''
        )
    SQL

    # Deleting duplicate keys where value is the same
    connection.execute <<-SQL
      DELETE FROM translations t1
      WHERE EXISTS
        (SELECT 1 FROM translations t2
          WHERE t1.instance_id = t2.instance_id AND  t1.locale = t2.locale
          AND t1.key = t2.key AND t1.id < t2.id AND t1.value = t2.value
        )
    SQL

    # Deleting duplicate keys which were updated further in the past
    connection.execute <<-SQL
      DELETE FROM translations t1
      WHERE EXISTS
        (SELECT 1 FROM translations t2
          WHERE t1.instance_id = t2.instance_id AND  t1.locale = t2.locale
          AND t1.key = t2.key AND t1.id != t2.id AND t1.value != t2.value
          AND t1.updated_at < t2.updated_at
        )
    SQL

    add_index :translations, [:instance_id, :locale, :key], unique: true
  end
end
