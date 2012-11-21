require 'csv'
include DesksnearMe::Application.routes.url_helpers
default_url_options[:host] = "desksnear.me"

namespace :export_csv_data do

  desc "Export listing data."
  task :listings => :environment do

    listings = Listing.all
    path = "tmp/csv_data/listings_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
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

  desc "Export user data."
  task :users => :environment do

    users = User.all
    path = "tmp/export_csv_data/users_#{Time.now.strftime('%Y-%m-%d')}.csv"

    CSV.open(path, File::WRONLY|File::CREAT|File::EXCL) do |csv|

      csv << [
        "user.name",
        "user.email",
        "user.created_at",
        "user.last_sign_in_at"
      ]

      users.each do |user|
        csv << [
          user.name,
          user.email,
          user.created_at.strftime('%Y-%m-%d'),
          user.last_sign_in_at.try(:strftime, '%Y-%m-%d')
        ]
      end

    end

    puts "Users exported to #{path}."
  end

end
