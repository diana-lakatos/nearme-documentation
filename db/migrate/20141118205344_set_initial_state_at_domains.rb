class SetInitialStateAtDomains < ActiveRecord::Migration
  class Domain < ActiveRecord::Base
  end

  def up
    Domain.unscoped.where(state: nil).update_all(state: :unsecured)
  end

  def down
  end
end
