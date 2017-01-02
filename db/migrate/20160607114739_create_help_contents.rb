# frozen_string_literal: true
class CreateHelpContents < ActiveRecord::Migration
  def change
    create_table :help_contents do |t|
      t.string :slug, null: false
      t.text :content

      t.timestamps null: false
    end

    add_index :help_contents, :slug, unique: true
  end
end
