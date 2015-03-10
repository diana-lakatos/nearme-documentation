class AddMailingAddressIdToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :mailing_address_id, :integer, index: true

    FormComponent.all.each do |form_component|
      changed = false
      form_component.form_fields.each do |form_field|
        key = form_field.keys.first
        if form_field[key] == 'mailing_address'
          changed = true
          form_field[key] = 'payments_mailing_address'
        end
      end

      form_component.save! if changed
    end
  end

  def self.down
    remove_column :companies, :mailing_address_id, :integer
  end
end
