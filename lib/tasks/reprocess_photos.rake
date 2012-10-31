namespace :reprocess do
  desc "Reprocess all the photos"
  task :photos => :environment do
    Photo.all.each { |p| p.image.recreate_versions! }
  end
end
