class IntroduceManyToManyBetweenTransactableTypeAndLocalesAndInstanceViews < ActiveRecord::Migration
  def up
    create_table :transactable_type_instance_views do |t|
      t.integer :instance_id
      t.integer  :instance_view_id
      t.integer  :transactable_type_id
      t.timestamps
      t.index [:instance_id, :instance_view_id, :transactable_type_id ], name: 'index_tt_instance_views_on_instance_id_tt_view_unique', unique: true
    end

    create_table :locale_instance_views do |t|
      t.integer :instance_id
      t.integer  :instance_view_id
      t.integer  :locale_id
      t.timestamps
      t.index [:instance_id, :instance_view_id, :locale_id ], name: 'index_tt_instance_views_on_instance_id_locale_view_unique', unique: true
    end
    remove_index :instance_views, name: 'instance_path_with_format_and_handler'
    add_index :instance_views, [:instance_id, :path, :format, :handler], name: 'instance_path_with_format_and_handler'

    Instance.find_each do |i|
      puts "Processing #{i.name}"
      i.set_context!
      primary_locale = Locale.find_by(code: i.primary_locale) || Locale.first
      i.instance_views.each do |iv|
        if iv.transactable_type_id.present?
          begin
            iv.transactable_types << TransactableType.find(iv.transactable_type_id)
          rescue
            puts "\tWarning: #{iv.path}(id=#{iv.id}) is associated with TT #{iv.transactable_type_id} but it does not exist"
          end
        end
        if primary_locale
          iv.locales = [primary_locale]
        else
          puts "No locale!"
        end
      end
    end


  end

  def down
    drop_table :transactable_type_instance_views
    drop_table :locale_instance_views
  end

end

