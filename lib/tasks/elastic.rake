require 'ansi/progressbar'

namespace :elastic do
  desc 'Re-creates and fills defined indexes'
  task :reindex => [:environment] do
    Transactable.__elasticsearch__.create_index! force: true
    Transactable.searchable.import force: true
    Spree::Product.__elasticsearch__.create_index! force: true
    Spree::Product.searchable.import force: true
  end

  desc 'Updates index and documents'
  task update: :environment do
    puts 'Updating Transactables index mappings'
    puts Transactable.__elasticsearch__.client.indices.put_mapping index: 'transactables', type: 'transactable', body: Transactable.mappings
    puts 'Updating documents in Transactables index'
    pbar = ANSI::Progressbar.new('Transactable', Transactable.searchable.count)
    pbar.__send__ :show if pbar
    Transactable.searchable.import batch_size: 100 do |response|
      pbar.inc response['items'].size if pbar
    end
    pbar.finish
    puts 'Updating Products index mappings'
    puts Spree::Product.__elasticsearch__.client.indices.put_mapping index: 'spree-products', type: 'product', body: Spree::Product.mappings
    puts 'Updating documents in Products index'
    pbar = ANSI::Progressbar.new('Product', Transactable.searchable.count)
    pbar.__send__ :show if pbar
    Spree::Product.searchable.import batch_size: 100 do |response|
      pbar.inc response['items'].size if pbar
    end
    pbar.finish
  end
end
