class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :type
      t.string :file
      t.references :attachable, index: true, polymorphic: true
      t.references :instance, index: true
      t.references :user, index: true
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :payment_document_infos do |t|
      t.references :document_requirement, index: true
      t.references :attachment, index: true
      t.references :instance, index: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
