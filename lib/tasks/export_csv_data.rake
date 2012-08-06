require 'csv'
include DesksnearMe::Application.routes.url_helpers
default_url_options[:host] = "desksnear.me"

namespace :export_csv_data do
  desc "Export specified data to tmp directory in CSV format."
  task :listings => :environment do

    listings = listing.all
    path = "tmp/export_csv_data/listings.csv"

    CSV.open(path, "wb") do |csv|

      csv << ["Name", "Max Desks", "Description", "Company Description", "Address", "Creator Name", "Creator Email", "Created", "URL", "Formatted Address", "No. Reservations", "Link"]

      listings.each do |w|
        csv << [w.name, w.quantity, w.description, w.company_description, w.address, w.creator.name, w.creator.email, w.created_at.strftime('%m/%d/%Y'), w.url, w.formatted_address, w.reservations_count, listing_url(w)]
      end

    end

    puts "listings exported to #{path}."

  end
end
