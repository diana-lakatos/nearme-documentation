class ConvertTaxonsToCategories < ActiveRecord::Migration
  def up
    convert_to_categories(Spree::Taxon.roots)
  end

  def down
  end

  def convert_to_categories(taxons, parent_id=nil)
    taxons.each do |taxon|
      PlatformContext.current = PlatformContext.new(Instance.find(taxon.instance_id)) if parent_id.nil?
      product_type = Spree::ProductType.first
      next if product_type.nil? # jump to next when currently no product types added
      category = product_type.categories.create(taxon.attributes.slice('name', 'position').merge(parent_id: parent_id))
      puts "Created new category called #{category.name} with id #{category.id} for product_type #{instance.name}"
      category.products = taxon.products
      convert_to_categories(taxon.children, category.id)
    end
  end
end
