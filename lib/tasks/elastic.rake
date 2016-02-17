namespace :elastic do
  desc 'Re-creates and fills defined indexes'
  task :reindex => [:environment] do
    Transactable.__elasticsearch__.create_index! force: true
    Transactable.searchable.import force: true
    Spree::Product.__elasticsearch__.create_index! force: true
    Spree::Product.searchable.import force: true
  end
end
