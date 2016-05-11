
namespace :migrate_spree do

  task to_shipping_profiles: :environment do
    Instance.find_each do |instance|
      instance.set_context!
      puts "Migrating Shipping Profiles for instance #{instance.id} - #{instance.name}"
      Spree::ShippingCategory.where(instance_id: instance).find_each do |sc|
        sp = ShippingProfile.where(sc.slice(:name, :company_id, :partner_id, :user_id, :instance_id)).first_or_initialize
        sp.global = sc.is_system_profile
        sc.shipping_methods.map do |sm|
          sm_countries = sm.zones.map(&:countries).compact.flatten
          sr = sp.shipping_rules.new(
            name: sm.name,
            processing_time: sm.processing_time,
            is_worldwide: sm_countries.blank?,
            price: sm.calculator.try(:preferred_amount).to_i <= TransactableType::Pricing::MAX_PRICE ? sm.calculator.try(:preferred_amount).to_i : 0
          )
          sr.countries = Country.where(iso: sm_countries.map(&:iso)) if sm_countries.present?
        end if sp.shipping_rules.empty?
        sp.save!
      end
    end
  end

  task to_action_types: :environment do
    class Spree::ProductType < TransactableType; end;

    Instance.where.not(id: [80, 103]).find_each do |instance|
      instance.set_context!
      puts "Migrating Spree for instance #{instance.id} - #{instance.name}"
      TransactableType.unscoped.where(type: 'Spree::ProductType', instance_id: instance.id).where(deleted_at: nil).find_each do |spt|
        puts "Migrating Product type #{spt.id} - #{spt.name}"
        tt = TransactableType.unscoped.where(name: spt.name, type: 'TransactableType', instance_id: instance.id).where(deleted_at: nil)
        tt = tt.first_or_initialize
        tt.assign_attributes(spt.attributes.except('id', 'type'))
        tt.skip_location = true
        tt.enable_photo_required = false
        tt.show_page_enabled = true

        purchase_action = create_action(tt, 'purchase_action', instance)
        create_pricing_for_tt(purchase_action, tt, 'item', 1, instance) if purchase_action.pricings.empty?
        tt.action_types << purchase_action
        tt.custom_csv_fields = TransactableType::CsvFieldsBuilder.new(tt, [:company]).all_valid_object_field_pairs
        tt.save!
        FormComponent.where(form_componentable_type: 'Spree::ProductType', form_componentable_id: spt.id).each do |fc|
          tt_fc = fc.dup
          tt_fc.form_type = fc.form_type == 'product_attributes' ? 'transactable_attributes' : fc.form_type
          tt_fc.form_componentable = tt
          tt_fc.form_fields.each{|ff| ff["transactable"] = ff.delete("product")}
          tt_fc.save!
        end if tt.form_components.empty?
        DataUpload.where(importable_type: 'Spree::ProductType', importable_id: spt.id).each do |du|
          tt_du = du.dup
          tt_du.importable = tt
          tt_du.save
        end if tt.data_uploads.empty?
        CustomAttributes::CustomAttribute.where(target_type: 'Spree::ProductType', target_id: spt.id).each do |ca|
          tt_ca = ca.dup
          tt_ca.target = tt
          tt_ca.save
        end if tt.custom_attributes.empty?
        CustomValidator.where(validatable_type: 'Spree::ProductType', validatable_id: spt.id).each do |cv|
          tt_cv = cv.dup
          tt_cv.validatable = tt
          tt_cv.save!
        end if tt.custom_validators.empty?
        CategoryLinking.where(category_linkable_type: 'Spree::ProductType', category_linkable_id: spt.id).each do |cl|
          tt_cl = cl.dup
          tt_cl.category_linkable = tt
          tt_cl.save!
        end if tt.category_linkings.empty?
        RatingSystem.where(transactable_type_id: spt.id).each do |rs|
          tt_rs = rs.dup
          tt_rs.transactable_type = tt
          tt_rs.save!
        end

        Spree::Product.where(product_type_id: spt.id).find_each(batch_size: 100) do |product|
          t = tt.transactables.where(product.slice(:name, :description, :company_id, :external_id)).first_or_initialize
          next if t.purchase_action && t.purchase_action.pricings.any?
          t.assign_attributes(product.slice(
            :company_id,
            :deleted_at,
            :slug,
            :administrator_id,
            :draft,
            :average_rating,
            :wish_list_items_count,
            :featured
          ))
          t.instance_id = product.instance_id
          t.listings_public = true
          t.spree_product_id = product.id
          t.properties = product.extra_properties.to_liquid
          t.creator_id = product.user_id
          t.insurance_value = product.insurance_amount
          t.quantity = product.total_on_hand
          t.enabled = true
          t.shipping_profile = get_shipping_profile(product) if product.shipping_category
          t.categories_categorizables = product.categories_categorizables.map do |cat_cat|
            tt_cat_cat = cat_cat.dup
            tt_cat_cat.categorizable = t
            tt_cat_cat
          end if t.categories_categorizables.empty?
          t.categories = t.categories_categorizables.map(&:category).compact if t.categories.empty? && t.categories_categorizables.any?
          t.upload_obligation = product.upload_obligation.dup if product.upload_obligation
          t.document_requirements = product.document_requirements.map(&:dup)

          unless Rails.env.development?
            t.photos << product.images.map do |image|
              t.photos.new(
                remote_image_url: image.image.url,
                instance: instance,
                creator_id: image.uploader_id,
                caption: image.alt
              )
            end
          end
          product.company.update!(creator_id: product.user_id) if product.company.creator_id.nil?
          t.location = product.company.locations.first || product.company.locations.new(product.slice(:company_id, :administrator_id).merge({instance: instance, listings_public: true}))
          t.location.transactable_type = tt
          t.location.creator_id ||= product.user_id
          t.action_type = Transactable::PurchaseAction.new(
            instance: instance,
            transactable: t,
            transactable_type_action_type: purchase_action,
            enabled: true,
            no_action: tt.action_na,
            action_rfq: t.action_rfq
          )
          create_pricing_for_t(t.action_type, t, purchase_action.pricings.first, product.price.to_money(Spree::Config.currency), 'item', 1, instance)
          t.save(validate: false)
          product.images.each do |image|
            Photo.new(
              image.slice(:image_transformation_data, :image_original_url, :image_versions_generated_at, :image_original_height, :image_original_width).merge({
                owner: t,
                instance: instance,
                creator_id: image.uploader_id,
                caption: image.alt,
                skip_metadata: true
              })
            ).save(validate: false) rescue nil
          end if t.photos.empty?
          Review.where(reviewable:  product).each do |rev|
            tt_rev = rev.dup
            tt_rev.reviewable = t
            tt_rev.transactable_type = tt
            tt_rev.rating_system = rev.rating_system && tt.rating_systems.where(subject: rev.rating_system.subject).first
          end if t.reviews.empty?
        end
      end
    end
  end
end

def get_shipping_profile(product)
  return nil if product.company.shipping_profiles.none?
  if product.company.shipping_profiles.one?
    product.company.shipping_profiles.first
  else
    product.company.shipping_profiles.where(name: product.shipping_category.name, user_id: product.shipping_category.user_id).first
  end
end

def create_pricing_for_t(purchase, t, tt_pricing, price, unit, number_of_units, instance)
  purchase.pricings.new(
    enabled: true,
    instance: instance,
    action: purchase,
    transactable_type_pricing: tt_pricing,
    number_of_units: number_of_units,
    unit: unit,
    price: price,
    has_exclusive_price: false,
    is_free_booking: price <= 0
  )
end

def create_pricing_for_tt(tt_action, tt, unit, number_of_units, instance)
  tt_action.pricings.new(
    instance: instance,
    number_of_units: number_of_units,
    unit: unit,
    allow_exclusive_price: false,
    allow_book_it_out_discount: false,
    allow_free_booking: true
  )
end


def create_action(tt, type, instance)
  tt.send(type) || tt.send("build_#{type}",
    tt.slice(
      :service_fee_guest_percent,
      :service_fee_host_percent
    ).merge({
      instance: instance,
      enabled: true,
      allow_no_action: tt.action_na,
      allow_action_rfq: tt.action_rfq
    })
  )
end

