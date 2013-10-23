class AddSearchScopeOptionToPartner < ActiveRecord::Migration

  class Partner < ActiveRecord::Base
  end

  def change
    add_column :partners, :search_scope_option, :string, default: 'no_scoping'

    Partner.update_all(search_scope_option: 'no_scoping')
  end
end
