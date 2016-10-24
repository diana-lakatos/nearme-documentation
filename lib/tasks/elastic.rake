require 'ansi/progressbar'

namespace :elastic do
  desc 'Re-creates and fills defined indexes'
  task reindex: [:environment] do
    # DO NOT RUN THIS MANUALLY -> DESTROYS THE INDEX. PlatformContext does not matter
    Transactable.__elasticsearch__.create_index! force: true
    Transactable.searchable.import force: true
  end

  desc 'Re-creates and fills user index'
  task reindex_users: [:environment] do
    # DO NOT RUN THIS MANUALLY -> DESTROYS THE INDEX. PlatformContext does not matter
    User.__elasticsearch__.create_index! force: true
    User.import force: true
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
  end
end
