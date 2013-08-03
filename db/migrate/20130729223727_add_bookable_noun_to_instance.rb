class AddBookableNounToInstance < ActiveRecord::Migration
  def change
    add_column :instances, :bookable_noun, :string, :default => 'Desk'
  end
end
