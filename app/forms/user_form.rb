# frozen_string_literal: true
class UserForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  include Sync::SkipUnchanged
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (user_profiles_configuration = configuration.delete(:profiles)).present?
          validation = user_profiles_configuration.delete(:validation)
          validates :profiles, validation if validation.present?
          property :profiles, form: UserProfilesForm.decorate(user_profiles_configuration),
                              from: :profiles_open_struct
        end
        if (transactables_configuration = configuration.delete(:transactables)).present?
          validation = transactables_configuration.delete(:transactables)
          validates :transactables, validation if validation.present?
          property :transactables, form: TransactablesForm.decorate(transactables_configuration),
                                   from: :transactables_open_struct
        end
        if (companies_configuration = configuration.delete(:companies)).present?
          validation = companies_configuration.delete(:validation)
          validates :companies, validation if validation.present?
          collection :companies, form: CompanyForm.decorate(companies_configuration),
                                 populate_if_empty: Company,
                                 prepopulator: ->(*) { companies << Company.new if companies.size.zero? }
        end
        if (current_address_configuration = configuration.delete(:current_address))
          validation = (current_address_configuration || {}).delete(:validation)
          validates :current_address, validation if validation.present?
          property :current_address, form: AddressForm.decorate(current_address_configuration),
                                     populator: ->(model:, **) { self.current_address ||= Address.new },
                                     prepopulator: ->(*) { self.current_address ||= Address.new }
        end
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end

  property :tag_list
  property :email
  property :external_id, virtual: true
  property :password

  validate :email_uniqueness, if: :email_changed?
  validates :email, email: true, presence: true
  validates_with PasswordValidator, if: -> { password.present? && !(new_record? && model.authentications.size.positive?) }
  def email_uniqueness
    errors.add(:email, :taken) if User.admin.where(email: email).exists?
    errors.add(:email, :taken) if external_id.blank? && User.where(email: email).exists?
  end

  model :user

  def email=(email)
    @email_changed = email != model.email
    super
  end

  def email_changed?
    @email_changed
  end
end
