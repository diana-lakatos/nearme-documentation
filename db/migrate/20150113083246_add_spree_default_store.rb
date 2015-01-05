class AddSpreeDefaultStore < ActiveRecord::Migration
  def change
    Spree::Store.default.update(
      name: Instance.default_instance.name,
      url: Instance.default_instance.domains.first.name,
      meta_description: Instance.default_instance.theme.description,
      meta_keywords: Instance.default_instance.theme.tagline,
      seo_title: Instance.default_instance.theme.meta_title,
      default_currency: 'USD'
    )
  end
end
