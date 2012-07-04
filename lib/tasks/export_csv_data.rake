require 'csv'
include DesksnearMe::Application.routes.url_helpers
default_url_options[:host] = "desksnear.me"

namespace :export_csv_data do
  desc "Export specified data to tmp directory in CSV format."
  task :workplaces => :environment do

    workplaces = Workplace.all
    path = "tmp/export_csv_data/workplaces.csv"

    CSV.open(path, "wb") do |csv|

      csv << ["Name", "Max Desks", "Description", "Company Description", "Address", "Creator Name", "Creator Email", "Created", "URL", "Formatted Address", "No. Bookings", "Link"]

      workplaces.each do |w|
        csv << [w.name, w.maximum_desks, w.description, w.company_description, w.address, w.creator.name, w.creator.email, w.created_at.strftime('%m/%d/%Y'), w.url, w.formatted_address, w.bookings_count, workplace_url(w)]
      end

    end

    puts "Workplaces exported to #{path}."

  end
end
