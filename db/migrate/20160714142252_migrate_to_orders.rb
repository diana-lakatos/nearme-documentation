class MigrateToOrders < ActiveRecord::Migration
  def change
    Rake::Task['migrate:checkout_to_form_components'].invoke
    # Rake::Task['migrate:reservations_to_orders'].invoke
    # Rake::Task['migrate:recurring_booking_to_orders'].invoke
    # Rake::Task['migrate:spree_orders_to_orders'].invoke
  end
end
