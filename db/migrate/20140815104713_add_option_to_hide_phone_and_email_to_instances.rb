class AddOptionToHidePhoneAndEmailToInstances < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
    has_many :text_filters
  end

  class TextFilter < ActiveRecord::Base
  end

  def up
    add_column :instances, :apply_text_filters, :boolean, default: false

    create_table :text_filters do |t|
      t.string :name
      t.string :regexp
      t.string :replacement_text
      t.integer :flags
      t.integer :instance_id
      t.integer :creator_id
      t.datetime :deleted_at
      t.timestamps
    end

    @instance = Instance.find_by_id(20)
    if @instance
      @instance.text_filters.create(name: 'Email', regexp: '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}', flags: Regexp::IGNORECASE, replacement_text: '[FILTERED]')
      @instance.text_filters.create(name: 'Ten digits phone', regexp: '\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})', replacement_text: '[FILTERED]')
      @instance.text_filters.create(name: 'Seven digits phone', regexp: '(?:\(?([0-9]{3})\)?[-. ]?)?([0-9]{3})[-. ]?([0-9]{4})', replacement_text: '[FILTERED]')
      @instance.text_filters.create(name: 'Phone with leading 1', regexp: '(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})', replacement_text: '[FILTERED]')
    end
  end

  def down
    remove_column :instance, :apply_text_filters
    drop_table :text_filters
  end

end
