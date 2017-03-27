require 'json'

namespace :mpbuilder do
  desc 'Run all configuration methods for marketplace builder'

  task run: :environment do
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'])
  end

  task all: :environment do
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'])
  end

  task frontend: :environment do
    creators = [
      MarketplaceBuilder::Creators::ContentHoldersCreator,
      MarketplaceBuilder::Creators::LiquidViewsCreator,
      MarketplaceBuilder::Creators::PagesCreator,
      MarketplaceBuilder::Creators::FormConfigurationsCreator,
      MarketplaceBuilder::Creators::GraphQueriesCreator,
      MarketplaceBuilder::Creators::CustomThemesCreator,
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end

  task user_profiles: :environment do
    creators = [
      MarketplaceBuilder::Creators::InstanceProfileTypesCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end

  task translations: :environment do
    creators = [
      MarketplaceBuilder::Creators::TranslationsCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end

  task mailers: :environment do
    creators = [
      MarketplaceBuilder::Creators::MailersCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end
end
