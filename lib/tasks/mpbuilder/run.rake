require 'json'

namespace :mpbuilder do
  desc 'Run all configuration methods for marketplace builder'

  task run: :environment do
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'])
  end

  task all: :environment do
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'])
  end

  task liquid_views: :environment do
    creators = [
      MarketplaceBuilder::Creators::LiquidViewsCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end

  task content_holders: :environment do
    creators = [
      MarketplaceBuilder::Creators::ContentHoldersCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end

  task views: :environment do
    creators = [
      MarketplaceBuilder::Creators::ContentHoldersCreator,
      MarketplaceBuilder::Creators::LiquidViewsCreator,
      MarketplaceBuilder::Creators::PagesCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end

  task user_profiles: :environment do
    creators = [
      MarketplaceBuilder::Creators::InstanceProfileTypesCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end
end
