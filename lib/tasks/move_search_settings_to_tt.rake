namespace :search_settings do
  desc 'moves search settings from Istance to TransactableType'
  task move_to_tt: :environment do
    class Instance < ActiveRecord::Base
      has_many :transactable_types
      store_accessor :search_settings, :date_pickers, :tt_select_type, :date_pickers_mode, :default_products_search_view,
                     :date_pickers_use_availability_rules, :taxonomy_tree, :saved_search, :price_slider, :price_types

      def taxonomy_tree
        super == '1'
      end

      def price_slider
        super == '1'
      end

      def price_types
        super == '1'
      end

      def date_pickers
        super == '1'
      end

      def date_pickers_use_availability_rules
        super == '1'
      end

      def saved_search
        super == '1'
      end
    end

    Instance.find_each do |instance|
      TransactableType.unscoped.where(deleted_at: nil, instance_id: instance.id).find_each do |tt|
        tt.update_columns({
          default_search_view: instance.default_search_view.in?(tt.available_search_views) ? instance.default_search_view : tt.available_search_views.first,
          search_engine: instance.search_engine,
          searcher_type: instance.searcher_type,
          search_radius: instance.search_radius,
          show_categories: instance.taxonomy_tree,
          category_search_type: instance.category_search_type,
          allow_save_search: instance.saved_search,
          show_price_slider: instance.price_slider,
          search_price_types_filter: instance.price_types,
          show_date_pickers: instance.date_pickers,
          date_pickers_use_availability_rules: instance.date_pickers_use_availability_rules,
          date_pickers_mode: instance.date_pickers_mode
        })
        raise "TransactableType id: #{id} not valid after change" unless tt.reload.valid?
      end
    end
  end

end