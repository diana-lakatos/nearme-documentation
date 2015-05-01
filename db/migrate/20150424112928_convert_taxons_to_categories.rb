class ConvertTaxonsToCategories < ActiveRecord::Migration
  def up
    convert_to_categories(Spree::Taxon.roots)
  end

  def down
  end

  def convert_to_categories(taxons, parent_id=nil)
    taxons.each do |taxon|
      instance = Instance.find(taxon.instance_id)
      PlatformContext.current = PlatformContext.new(instance) if parent_id.nil?
      product_type = Spree::ProductType.first
      unless product_type.nil?
        category = product_type.categories.create(taxon.attributes.slice('name', 'position').merge(parent_id: parent_id, search_options: 'exclude', display_options: 'tree'))
        puts "Created new category called #{category.name} with id #{category.id} for product_type #{instance.name}"
        category.products = taxon.products
        convert_to_categories(taxon.children, category.id)
      end
    end
  end
end
