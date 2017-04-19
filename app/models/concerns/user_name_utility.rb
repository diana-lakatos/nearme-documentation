# frozen_string_literal: true
module UserNameUtility
  MAX_NAME_LENGTH = 30

  extend ActiveSupport::Concern

  included do
    validates :name, :first_name, presence: true

    before_validation :prepare_name_fields

    delegate :to_s, to: :name

    def name
      self[:last_name].present? ? full_name_from_parts : self[:name]
    end

    def first_name
      self[:first_name].presence || first_name_from_name
    end

    def last_name
      self[:last_name].presence || last_name_from_name
    end

    def name_with_state
      name + (deleted? ? ' (Deleted)' : (banned? ? ' (Banned)' : ''))
    end

    def secret_name
      secret_name = last_name.present? ? last_name[0] : middle_name.try(:[], 0)
      secret_name = secret_name.present? ? "#{first_name} #{secret_name[0]}." : first_name

      if properties.try(:is_intel) == true
        secret_name += ' (Intel)'
        secret_name.html_safe
      else
        secret_name
      end
    end

    private

    def full_name_from_parts
      [first_name.presence, middle_name.presence, last_name.presence].compact.join(' ')
    end

    def prepare_name_fields
      self.first_name = name&.split&.first unless first_name.present?
      self.name = full_name_from_parts unless name.present?
    end

    def last_name_from_name
      (self[:name] || '').split[1..-1]&.join(' ')
    end

    def first_name_from_name
      self[:name]&.split&.first
    end
  end
end
