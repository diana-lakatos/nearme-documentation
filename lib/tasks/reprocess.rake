namespace :reprocess do
  desc "Reprocess all of the instance's themes"
  task :css => :environment do
    InstanceTheme.find_each do |i|
      begin
        i.recompile_theme
        puts "Reprocessed Instance Theme ##{i.id} CSS successfully"
      rescue
        puts "Reprocessing Instance Theme ##{i.id} CSS failed: #{$!.inspect}"
      end
    end
  end
  
  desc "Reprocess all the photos"
  task :photos => :environment do
    Photo.find_each do |p|
      begin
        p.image.recreate_versions!
        puts "Reprocessed Photo##{p.id} successfully"
      rescue
        puts "Reprocessing Photo##{p.id} failed: #{$!.inspect}"
      end
    end
  end
end
