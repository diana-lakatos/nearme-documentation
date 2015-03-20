class CreateLocales < ActiveRecord::Migration
  class Locale < ActiveRecord::Base
  end

  class Instance < ActiveRecord::Base
  end

  def up
    create_table :locales do |t|
      t.integer :instance_id
      t.string :code
      t.string :custom_name
      t.boolean :primary, default: false

      t.timestamps
    end

    Instance.pluck(:id, :name).each do |instance|
      puts "Creating English locale for: #{instance[1]}"
      Locale.create! instance_id: instance[0], code: 'en', primary: true
    end
  end

  def down
    drop_table :locales
  end
end
