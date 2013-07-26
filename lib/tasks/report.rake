require 'csv'
include DesksnearMe::Application.routes.url_helpers
default_url_options[:host] = "desksnear.me"

namespace :report do

  #### GLOBAL

  desc "Export CSV data."
  task :all => [:summary, :users, :companies, :locations, :listings, :reservations, :search_queries]

  #### SUMMARY

  desc "Export summary statistics."
  task :summary => :environment do

    metrics = []

    ["User", "Company", "Location", "Listing", "Reservation", "Inquiry", "SearchQuery"].each do |metric|

      m = eval(metric)
      new_this_week = m.where("created_at > ?", Time.now - 7.days).size
      total = m.all.size

      metrics << { :name => metric, :new_this_week => new_this_week, :total => total }

    end

    path = "tmp/csv_data/summary_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "metric", "new_this_week", "total"
      ]

      metrics.each do |metric|
        csv << [
          metric[:name],
          metric[:new_this_week],
          metric[:total]
        ]
      end

    end

    puts "Summary exported to #{path}."
  end

  #### USERS

  desc "Export user data."
  task :users => :environment do

    users = User.all
    path = "tmp/csv_data/users_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "new_this_week",
        "user.name",
        "user.email",
        "user.created_at",
        "user.last_sign_in_at"
      ]

      users.each do |user|
        csv << [
          user.created_at > (Time.now - 7.days) ? 1 : 0,
          user.name,
          user.email,
          user.created_at.strftime('%Y-%m-%d'),
          user.last_sign_in_at.try(:strftime, '%Y-%m-%d')
        ]
      end

    end

    puts "Users exported to #{path}."
  end

  #### COMPANIES

  desc "Export company data."
  task :companies => :environment do

    companies = Company.all
    path = "tmp/csv_data/companies_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "new_this_week",
        "name",
        "email",
        "description",
        "url",
        "user.name",
        "user.email"
      ]

      companies.each do |company|
        csv << [
          company.created_at > (Time.now - 7.days) ? 1 : 0,
          company.name,
          company.email,
          company.description,
          company.url,
          (company.creator.name if company.creator),
          (company.creator.email if company.creator)
        ]
      end

    end

    puts "Companies exported to #{path}."
  end

  #### LOCATIONS

  desc "Export listing data."
  task :locations => :environment do

    locations = Location.all
    path = "tmp/csv_data/locations_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "new_this_week",
        "user.name",
        "user.email",
        "user.phone",
        "company.email",
        "company.name",
        "company.url",
        "location.name",
        "location.address",
        "location.description",
        "location.email",
        "location.info",
        "location.phone"
      ]

      locations.each do |location|
        csv << [
          location.created_at > (Time.now - 7.days) ? 1 : 0,
          (location.creator.name if location.creator),
          (location.creator.email if location.creator),
          (location.creator.phone if location.creator),
          location.company.email,
          location.company.name,
          location.company.url,
          location.name,
          location.address,
          location.description,
          location.email,
          location.info,
          location.phone
        ]
      end

    end

    puts "Locations exported to #{path}."
  end

  #### LISTINGS

  desc "Export listing data."
  task :listings => :environment do

    listings = Listing.all
    path = "tmp/csv_data/listings_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "new_this_week",
        "user.name",
        "user.email",
        "user.phone",
        "company.email",
        "company.name",
        "company.url",
        "location.name",
        "location.address",
        "location.description",
        "location.email",
        "location.info",
        "location.phone",
        "listing.name",
        "listing.description",
        "listing.quanity",
        "listing.created_at",
        "listing_url"
      ]

      listings.each do |listing|
        csv << [
          listing.created_at > (Time.now - 7.days) ? 1 : 0,
          listing.creator.name,
          listing.creator.email,
          listing.creator.phone,
          listing.company.email,
          listing.company.name,
          listing.company.url,
          listing.location.name,
          listing.location.address,
          listing.location.description,
          listing.location.email,
          listing.location.info,
          listing.location.phone,
          listing.name,
          listing.description,
          listing.quantity,
          listing.created_at.strftime('%Y-%m-%d'),
          listing_url(listing)
        ]
      end

    end

    puts "Listings exported to #{path}."
  end

  #### RESERVATIONS

  desc "Export reservation data."
  task :reservations => :environment do

    reservations = Reservation.all
    path = "tmp/csv_data/reservations_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "week",
        "reservations"
      ]

      grouped_reservations = reservations.group_by{ |r| r.created_at.strftime('%Y-%W') }.sort

      grouped_reservations.each do |week, reservations|

        csv << [
          week,
          reservations.size
        ]

      end

    end

    puts "Listings exported to #{path}."
  end

  #### Locations without listings

  desc "Export locations with no associated listings"
  task :locations_without_listings => :environment do

    locations = Location.
      joins("left join listings on listings.location_id = locations.id").
      where("listings.location_id is null")

    path = path("locations_without_listings")

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "new_this_week",
        "user.name",
        "user.email",
        "user.phone",
        "company.email",
        "company.name",
        "company.url",
        "location.id",
        "location.name",
        "location.address",
        "location.description",
        "location.email",
        "location.info",
        "location.phone",
        "location_created_at"
      ]

      locations.each do |location|
        csv << [
          location.created_at > (Time.now - 7.days) ? 1 : 0,
          (location.creator.name if location.creator),
          (location.creator.email if location.creator),
          (location.creator.phone if location.creator),
          location.company.email,
          location.company.name,
          location.company.url,
          location.id,
          location.name,
          location.address,
          location.description,
          location.email,
          location.info,
          location.phone,
          location.created_at.strftime('%Y-%m-%d')
        ]
      end

    end

    puts "Locations without listings exported to #{path}."
  end

end

def path(name)
  "tmp/csv_data/#{name}_#{Time.now.strftime('%Y-%m-%d')}.csv"
end
