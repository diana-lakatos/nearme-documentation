class MigrateRequirePayout < ActiveRecord::Migration
  def change
    Rake::Task['migrate:update_require_payout'].invoke
  end
end
