class AddLanguageToSupportFaqs < ActiveRecord::Migration
  def self.up
    add_column :support_faqs, :language, :string, null: false, default: 'en'
  end

  def self.down
    remove_column :support_faqs, :language
  end
end
