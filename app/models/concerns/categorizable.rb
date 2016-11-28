# frozen_string_literal: true
module Categorizable
  extend ActiveSupport::Concern

  included do
    has_many :categories_categorizables, as: :categorizable
    has_many :categories, through: :categories_categorizables

    attr_accessor :categories_not_required

    # for now we do not require categories on sign up
    validate :validate_mandatory_categories, unless: ->(record) { record.categories_not_required || (UserProfile === record && record.new_record?) }

    def validate_mandatory_categories
      return true if Order === self
      # it could be use by just hala
      (Order === self ? reservation_type : transactable_type).categories.mandatory.each do |mandatory_category|
        errors.add(mandatory_category.name, I18n.t('errors.messages.blank')) if common_categories(mandatory_category).blank?
      end
    end

    def category_ids=(ids)
      return super(ids) unless ids.all? { |id| id.respond_to?(:gsub) }
      super(ids.map { |e| e.gsub(/\[|\]/, '').split(',') }.flatten.compact.map(&:to_i))
    end

    def common_categories(category)
      categories & category.descendants
    end

    def common_categories_json(category)
      JSON.generate(common_categories(category).map { |c| { id: c.id, name: c.translated_name } })
    end
  end
end
