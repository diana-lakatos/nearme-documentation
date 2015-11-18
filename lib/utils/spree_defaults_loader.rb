module Utils
  class SpreeDefaultsLoader

    def initialize(instance)
      @instance = instance
      @store = Spree::Store.find_by(instance_id: @instance.id)
    end

    def load!
      Instance.transaction do
        set_preferences
        load_countries
        load_roles
        load_states
        load_zones
        load_tax_categories_and_rates
        load_stock_location
        load_shipping_methods
        load_instance_serach_defaults
      end
    end

    private

    def set_preferences
      create_store unless @store.present?

      Spree.config do |config|
        config.require_master_price = false
        # config.allow_ssl_in_staging = false
        config.currency = 'USD'
      end
      # Spree::Config.address_requires_state = false
    end

    def create_store
      Spree::Store.create!(
          instance_id: @instance.id,
          name: @instance.theme.site_name || @instance.name,
          url: @instance.domains.first.name,
          meta_description: @instance.theme.description,
          meta_keywords: @instance.theme.tagline,
          seo_title: @instance.theme.meta_title,
          mail_from_address: @instance.support_email.present? ? @instance.support_email : "support@#{@instance.domains.first.name}",
          default_currency: 'USD',
          code: "#{@instance.id}-#{@instance.theme.site_name || @instance.name}"
      )
    end

    def load_instance_serach_defaults
      @instance.save
    end

    def load_roles
      Spree::Role.where(name: "admin").first_or_create
      Spree::Role.where(name: "user").first_or_create
    end

    def load_stock_location
      Spree::StockLocation.create!({
                                       name: 'default',
                                       country_id: Spree::Country.find_by_name('United States').id,
                                       active: true,
                                       backorderable_default: false,
                                       propagate_all_variants: true
                                   })
    end

    def load_zones
      eu_vat = Spree::Zone.new(name: "EU_VAT", description: "Countries that make up the EU VAT zone.")
      north_america = Spree::Zone.new(name: "North America", description: "USA + Canada", default_tax: true)

      eu_countries = %w(Austria Belgium Bulgaria Croatia Cyprus Czech\ Republic Denmark Estonia Finland
                        France Germany Greece Hungary Ireland Italy Latvia Lithuania Luxembourg Malta Netherlands Poland
                        Portugal Romania Slovakia Slovenia Spain Sweden United\ Kingdom)

      eu_countries.each do |name|
        eu_vat.zone_members.build(zoneable: Spree::Country.find_by!(name: name))
      end

      ['United States', 'Canada'].each do |name|
        north_america.zone_members.build(zoneable: Spree::Country.find_by!(name: name))
      end

      eu_vat.save!
      north_america.save!
    end

    def load_tax_categories_and_rates
      tax_category = Spree::TaxCategory.create!({
                                                    name: 'default',
                                                    description: 'default',
                                                    is_default: true
                                                })

      Spree::Zone.all.each do |zone|
        calculator = Spree::Calculator::DefaultTax.create!
        Spree::TaxRate.create!({
                                   amount: 0,
                                   zone: zone,
                                   tax_category: tax_category,
                                   name: '0',
                                   calculator: calculator
                               })
      end

      Spree::TaxRate.update_all(included_in_price: true)
    end

    def load_shipping_methods
      shipping_category = Spree::ShippingCategory.where(name: 'default').first_or_create!

      calculator = Spree::Calculator::Shipping::FlatRate.create!
      shipping_method = {
          name: 'default',
          zones: Spree::Zone.all,
          calculator: calculator,
          shipping_categories: [shipping_category],
          display_on: 'both'
      }

      shipping_method = Spree::ShippingMethod.create!(shipping_method)
      shipping_method.calculator.preferred_amount = 0
      shipping_method.calculator.preferred_currency = 'USD'
      shipping_method.calculator.calculable_type = 'Spree::ShippingMethod'
      shipping_method.calculator.calculable_id = shipping_method.id
      shipping_method.save!
    end

    def load_states
      return true if Spree::State.count > 0

      ActiveRecord::Base.transaction do
        Spree::Country.all.each do |country|
          carmen_country = Carmen::Country.named(country.name)
          @states ||= []
          if carmen_country.subregions?
            carmen_country.subregions.each do |subregion|
              @states << {
                  name: subregion.name,
                  abbr: subregion.code,
                  country: country
              }
            end
          end
        end

        Spree::State.create!(@states)
      end
    end

    def load_countries
      return true if Spree::Country.count > 0

      countries = []
      Carmen::Country.all.each do |country|
        countries << {
            name: country.name,
            iso3: country.alpha_3_code,
            iso: country.alpha_2_code,
            iso_name: country.name.upcase,
            numcode: country.numeric_code,
            states_required: country.subregions?
        }
      end

      ActiveRecord::Base.transaction do
        Spree::Country.create!(countries)
      end

      Spree::Config[:default_country_id] = Spree::Country.find_by(name: 'United States').id
    end
  end
end
