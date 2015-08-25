namespace :elastic do
  desc 'Re-creates and fills defined indexes'
  task :reindex => [:environment] do
    Instance.find_each do |i|
      i.set_context!
      Transactable.searchable.import force: true
      Spree::Product.searchable.import force: true
    end
  end
end