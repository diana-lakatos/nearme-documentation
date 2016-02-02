class Spree::ProductDecorator < Draper::Decorator
  include MoneyRails::ActionViewExtension
  include Draper::LazyHelpers

  delegate_all

  def humanized_price
    humanized_money_with_symbol(object.price.to_money(Spree::Config.currency))
  end

  def user_message_recipient
    administrator
  end

  def user_message_summary(user_message)
    link_to user_message.thread_context.name, product_path(user_message.thread_context)
  end

  def first_image_url
    if object.images.empty?
      asset_url 'placeholders/895x554.gif'
    else
      asset_url object.images.first.image_url
    end
  end

  def first_image
    if object.images.empty?
      image_tag 'placeholders/895x554.gif', id: 'product-first-image'
    else
      image_tag object.images.first.image_url, alt: object.images.first.alt, id: 'product-first-image'
    end
  end

  def short_description(chars=90)
    object.description.to_s.truncate chars, separator: ' '
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
