Spree::Taxonomy.class_eval do
  include Spree::Scoper
  private

  def set_name
    if root
      root.update_columns(
        name: name,
        updated_at: Time.now,
      )
    else
      self.root = Spree::Taxon.create!(taxonomy_id: id, name: name, company_id: company_id)
    end
  end
end
