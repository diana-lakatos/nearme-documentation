class AddQuantityToTransactables < ActiveRecord::Migration
  class Transactable < ActiveRecord::Base
  end

  def up
    add_column :transactables, :quantity, :integer, default: 1

    fix_command = <<-SQL
      UPDATE transactables SET properties = properties || '"quantity"=>"%new%"'::hstore WHERE properties->'quantity' = '%old%'
    SQL

    # Fix non-compatible values
    connection.execute(fix_command.gsub('%new%', '1').gsub('%old%', ''))
    connection.execute(fix_command.gsub('%new%', '1').gsub('%old%', '0'))
    connection.execute(fix_command.gsub('%new%', '14').gsub('%old%', '14 lots'))
    connection.execute(fix_command.gsub('%new%', '9').gsub('%old%', '8 - 10'))
    connection.execute(fix_command.gsub('%new%', '3').gsub('%old%', '3 Type'))
    connection.execute(fix_command.gsub('%new%', '8').gsub('%old%', '8/58'))

    # Update new column from hstore value
    connection.execute <<-SQL
      UPDATE transactables SET quantity = (properties->'quantity')::int
    SQL
  end

  def down
    remove_column :transactables, :quantity
  end
end
