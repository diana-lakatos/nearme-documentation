# frozen_string_literal: true
SimpleNavigation::Configuration.run do |navigation|
  navigation.id_generator = proc { |key| "nav-config-asset-#{key}" }

  navigation.items do |nav|
    nav.item :general, 'General Settings', admin_assets_general_settings_path(@transactable_type)
    nav.item :properties, 'Properties', admin_path(page: 'asset_wizard_properties')
    nav.item :location, 'Location', admin_path(page: 'asset_wizard_location')
    nav.item :booking, 'Booking', admin_path(page: 'asset_wizard_booking')
    nav.item :pricing, 'Pricing', admin_path(page: 'asset_wizard_pricing')
    nav.item :shipping, 'Shipping', admin_path(page: 'asset_wizard_shipping')
    nav.item :taxes, 'Taxes', admin_path(page: 'asset_wizard_taxes')
    nav.item :payments, 'Payments', admin_path(page: 'asset_wizard_payments')
    nav.item :"waiver-agreements", 'Waiver Agreements', admin_path(page: 'asset_wizard_waiver_agreements')
    nav.item :"file-uploads", 'File Uploads', admin_path(page: 'asset_wizard_file_uploads')
    nav.item :search, 'Search', admin_path(page: 'asset_wizard_search')
    nav.item :"form-layouts", 'Form layouts', admin_path(page: 'asset_wizard_form_layouts')
    nav.item :wtf, 'WTF', admin_path(page: 'asset_wizard_wtf')
    nav.item :delete_asset, 'Delete Asset', admin_path(page: 'asset_delete')
  end
end
