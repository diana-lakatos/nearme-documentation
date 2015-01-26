class CopyContactToSupportEmail < ActiveRecord::Migration
  def change
    Theme.all.each do |theme|
      theme.update_attribute(:support_email, theme.contact_email) if theme.support_email.blank?
    end
  end
end
