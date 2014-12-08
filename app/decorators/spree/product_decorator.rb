class Spree::ProductDecorator < Draper::Decorator
  include MoneyRails::ActionViewExtension
  include Draper::LazyHelpers

  delegate_all

  def humanized_price
    humanized_money_with_symbol(object.price.to_money(Spree::Config.currency))
  end

  def grouped_taxons
    @grouped_taxons ||=
      begin
        result = {}
        object.taxons.group_by(&:root).each do |taxon_root, taxons|
          result[taxon_root.name] ||= []
          result[taxon_root.name] << taxons.map(&:name)
        end
        result
      end
  end

  def cross_sell_products(exclude_product_ids=[], number_of_products=6)
    products_scope = Spree::Product.searchable.limit(number_of_products)
    products_scope = products_scope.where('spree_products.id NOT IN (?)', exclude_product_ids) unless exclude_product_ids.empty?
    if object.cross_sell_skus.empty?
      if Spree::Config[:random_products_for_cross_sell]
        products_scope.order('random()')
      else
        []
      end
    else
      products_scope.ransack(variants_including_master_sku_in: object.cross_sell_skus).result
    end
  end

  def user_message_recipient
    administrator
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, product_path(user_message.thread_context)
  end

  private

  # Builds variants from a hash of option types & values
  def build_variants_from_option_values_hash
    ensure_option_types_exist_for_values_hash
    values = option_values_hash.values
    values = values.inject(values.shift) { |memo, value| memo.product(value).map(&:flatten) }

    values.each do |ids|
      variant = variants.create(
        option_value_ids: ids,
        price: master.price,
        company_id: master.company_id
      )
    end
    save
  end

  def ensure_master
    return unless new_record?
    self.master ||= Variant.new(company_id: self.company_id)
  end
end
