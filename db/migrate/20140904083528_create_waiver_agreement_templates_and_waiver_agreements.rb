class CreateWaiverAgreementTemplatesAndWaiverAgreements < ActiveRecord::Migration
  def change
    create_table :waiver_agreement_templates do |t|
      t.string :name
      t.text :content
      t.references :target, polymorphic: true, index: true
      t.integer  :instance_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :waiver_agreements do |t|
      t.string :vendor_name
      t.string :guest_name
      t.string :name
      t.text :content
      t.references :target, polymorphic: true, index: true
      t.references :waiver_agreement_template, index: true
      t.integer  :instance_id, index: true
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :assigned_waiver_agreement_templates do |t|
      t.references :target, polymorphic: true
      t.integer :waiver_agreement_template_id
      t.integer  :instance_id, index: true
      t.timestamps
    end
    add_index :assigned_waiver_agreement_templates, :waiver_agreement_template_id, name: 'awat_wat_id'
    add_index :assigned_waiver_agreement_templates, [:target_id, :target_type], name: 'awat_target_id_and_target_type'

  end
end
