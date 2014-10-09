class CreateApprovalRequests < ActiveRecord::Migration
  def up
    create_table :approval_requests do |t|
      t.string :state
      t.string :message
      t.string :notes
      t.integer :instance_id, index: true
      t.integer :approval_request_template_id, index: true
      t.integer :owner_id
      t.string :owner_type
      t.boolean :required_written_verification
      t.datetime :deleted_at

      t.index [:owner_id, :owner_type]
      t.timestamps
    end

    create_table :approval_request_templates do |t|
      t.integer :instance_id, index: true
      t.string :owner_type
      t.boolean :required_written_verification, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :approval_request_attachment_templates do |t|
      t.integer :instance_id, index: true
      t.integer :approval_request_template_id, index: true
      t.boolean :required, default: false
      t.string :label
      t.text :hint
      t.datetime :deleted_at
      t.timestamps
    end

    rename_table :confidential_files, :approval_request_attachments

    remove_column :instances, :onboarding_verification_required
    remove_column :approval_request_attachments, :state
    remove_column :approval_request_attachments, :owner_type
    remove_column :approval_request_attachments, :owner_id

    add_column :approval_request_attachments, :approval_request_id, :integer, index: true
    add_column :approval_request_attachments, :approval_request_attachment_template_id, :integer, index: true
    add_column :approval_request_attachments, :required, :boolean, default: false
    add_column :approval_request_attachments, :label, :string
  end

  def down
    drop_table :approval_requests
    drop_table :approval_request_templates
    drop_table :approval_request_attachment_templates

    remove_column :approval_request_attachments, :approval_request_id
    remove_column :approval_request_attachments, :approval_request_attachment_template_id
    remove_column :approval_request_attachments, :required
    remove_column :approval_request_attachments, :label
    add_column :approval_request_attachments, :state, :string
    add_column :approval_request_attachments, :owner_id, :integer
    add_column :approval_request_attachments, :owner_type, :string

    rename_table :approval_request_attachments, :confidential_files

    add_column :instances, :onboarding_verification_required, :boolean

  end
end

