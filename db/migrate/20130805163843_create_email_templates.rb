class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.references :instance
      t.text   :html_body
      t.text   :text_body
      t.string :path
      t.string :from
      t.string :to
      t.string :bcc
      t.string :reply_to
      t.string :subject
      t.boolean :partial, default: false

      t.timestamps
    end
    add_index :email_templates, :instance_id
    add_index :email_templates, [:path, :partial, :instance_id]
  end
end
