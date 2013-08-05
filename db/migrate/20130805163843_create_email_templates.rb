class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.references :instance
      t.string :type
      t.string :subject
      t.string :from
      t.text :body

      t.timestamps
    end
    add_index :email_templates, :instance_id
  end
end
