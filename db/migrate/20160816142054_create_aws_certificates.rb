class CreateAwsCertificates < ActiveRecord::Migration
  def change
    create_table :aws_certificates do |t|
      t.references :instance, null: false
      t.string :name, null: false
      t.datetime :elb_uploaded_at
      t.string :status
      t.string :arn
      t.string :certificate_type

      t.timestamps null: false
    end

    add_column :domains, :aws_certificate_id, :integer
  end
end
