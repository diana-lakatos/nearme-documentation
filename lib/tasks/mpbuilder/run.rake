require 'json'

namespace :mpbuilder do
  desc 'Run all configuration methods for marketplace builder'

  task run: :environment do
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'])
  end

  task liquid_views: :environment do
    creators = [
      MarketplaceBuilder::Creators::LiquidViewsCreator
    ]
    MarketplaceBuilder::Loader.load(ENV['source'], verbose: ENV['verbose'], creators: creators)
  end
end
