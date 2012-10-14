class RenameOldListingAvailabilityRules < ActiveRecord::Migration
  def up
    rename_column :listings, :availability_rules, :availability_rules_text
  end

  def down
    rename_column :listings, :availability_rules_text, :availability_rules
  end
end
