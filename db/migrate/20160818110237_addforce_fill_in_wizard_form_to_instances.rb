class AddforceFillInWizardFormToInstances < ActiveRecord::Migration
  def change
    add_column :instances, :force_fill_in_wizard_form, :boolean
  end
end
