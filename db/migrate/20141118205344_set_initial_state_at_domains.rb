class SetInitialStateAtDomains < ActiveRecord::Migration
  def up
    Domain.unscoped.update_all({ state: :unsecured }, { state: nil })
  end

  def down
  end
end
