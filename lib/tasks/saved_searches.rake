namespace :saved_searches do
  namespace :alerts do
    desc "Create saved search notification alerts"
    task create: :environment do
      Instance.find_each do |instance|
        PlatformContext.current = PlatformContext.new(instance)
        Utils::DefaultAlertsCreator::SavedSearchCreator.new.create_all!
      end
    end
  end
end
