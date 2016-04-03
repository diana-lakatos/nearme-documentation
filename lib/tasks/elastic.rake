namespace :elastic do
  desc 'Re-creates and fills defined indexes'
  task :reindex => [:environment] do
    Transactable.searchable.import force: true
    Spree::Product.searchable.import force: true
  end
end
