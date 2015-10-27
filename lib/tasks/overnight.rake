namespace :overnight do
  task :fix => :environment do
    Instance.find_each do |i|
      i.set_context!
      Transactable.with_deleted.where(booking_type: "overnight").joins(:reservations).uniq.find_each do |transactable|
        transactable.reservations.find_each do |reservation|
          last_period = reservation.periods.order("date DESC").first
          puts "processing reservation #{reservation.id} - #{last_period}"
          #reservation.add_period(last_period.date + 1.day)
          reservation.save!(validate: false)
        end
      end
    end
  end
end
