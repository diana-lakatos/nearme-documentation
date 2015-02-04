class FixDefaultTranslationsForNoBookingsHtml < ActiveRecord::Migration
  class Translation < ActiveRecord::Base
  end

  def change
    Translation.where(key: 'reservations.no_bookings_html', instance_id: nil).update_all(value: "You don't have any %{type} bookings. <a href='/search'>Find a %{bookable_nouns} near you!</a>")
  end
end

