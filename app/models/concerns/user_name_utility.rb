module UserNameUtility

  MAX_NAME_LENGTH = 30

  extend ActiveSupport::Concern

  included do

    validates :name, :first_name, presence: true
    validates :first_name, length: { maximum: UserNameUtility::MAX_NAME_LENGTH }
    validates :middle_name, length: { maximum: UserNameUtility::MAX_NAME_LENGTH }
    validates :last_name, length: { maximum: UserNameUtility::MAX_NAME_LENGTH }

    before_validation :prepare_name_fields

    delegate :to_s, to: :name

    def name
      self[:last_name].present? ? full_name_from_parts : self[:name]
    end

    def first_name
      self[:last_name].present? ? self[:first_name] : self[:name].split.first
    end

    def last_name
      self[:last_name].presence || self[:name].split.last
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
      "#{first_name} #{middle_name} #{last_name}"
    end

    def prepare_name_fields
      self.first_name = name.split.first unless first_name.present?
      self.name = full_name_from_parts unless name.present?
    end

  end
end
