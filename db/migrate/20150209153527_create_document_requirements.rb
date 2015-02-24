class CreateDocumentRequirements < ActiveRecord::Migration
  def change
    create_table :document_requirements do |t|
      t.string :label
      t.text :description
      t.references :item, index: true, polymorphic: true
      t.references :instance, index: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :document_requirements, :deleted_at
  end
end
