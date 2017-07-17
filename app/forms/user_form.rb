# frozen_string_literal: true
class UserForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  include Sync::SkipUnchanged

  class << self
    def decorate(configuration)
      Class.new(self) do
        if (user_profiles_configuration = configuration.delete(:profiles)).present?
          add_validation(:profiles, user_profiles_configuration)
          property :profiles, form: UserProfilesForm.decorate(user_profiles_configuration),
                              from: :profiles_open_struct
        end
        if (transactables_configuration = configuration.delete(:transactables)).present?
          add_validation(:transactables, transactables_configuration)
          property :transactables, form: TransactablesForm.decorate(transactables_configuration),
                                   from: :transactables_open_struct
        end
        if (companies_configuration = configuration.delete(:companies)).present?
          add_validation(:companies, companies_configuration)
          collection :companies, form: CompanyForm.decorate(companies_configuration),
                                 populate_if_empty: Company,
                                 prepopulator: ->(*) { companies << Company.new if companies.size.zero? }
        end
        if (current_address_configuration = configuration.delete(:current_address))
          add_validation(:current_address, current_address_configuration)
          property :current_address, form: AddressForm.decorate(current_address_configuration),
                                     populator: ->(model:, **) { self.current_address ||= Address.new },
                                     prepopulator: ->(*) { self.current_address ||= Address.new }
        end
        inject_dynamic_fields(configuration, whitelisted: [:group_member_ids, :banned_at, :email, :name, :phone, :country_name, :mobile_number, :company_name, :time_zone, :sms_notifications_enabled, :first_name, :middle_name, :last_name, :accept_emails, :saved_searches_alerts_frequency, :language, :featured, :click_to_call, :public_profile, :accept_terms_of_service, :avatar])
      end
    end
  end

  # @!attribute profiles
  #   Form for updating profiles for this user
  #   Example:
  #   ```
  #   {% fields_for profiles %}
  #     {% fields_for default, form: profiles %}
  #       {% fields_for properties, form: default %}
  #         {% input landline, form: properties, input_html-data-maskedinput: 'phone-land' %}
  #       {% endfields_for %}
  #     {% endfields_for %}
  #   {% endfields_for %}
  #   ```
  #   - for displaying a custom attribute input
  #   @return [UserProfilesForm]
  # @!attribute transactables
  #   Form for updating a user's transactable(s)
  #   @return [TransactablesForm]
  # @!attribute companies
  #   Form for updating a user's companies
  #   @return [Array<CompanyForm>]
  # @!attribute current_address
  #   Form for updating a user's address
  #   @return [AddressForm]

  # @!attribute name
  #   @return [String] name of the user
  # @!attribute phone
  #   @return [String] user's phone number
  # @!attribute country_name
  #   @return [String] user's country name
  # @!attribute mobile_number
  #   @return [String] user's mobile number
  # @!attribute company_name
  #   @return [String] company name for the user
  # @!attribute time_zone
  #   @return [String] time zone of the user
  # @!attribute sms_notifications_enabled
  #   @return [Boolean] whether the user has sms notifications enabled
  # @!attribute first_name
  #   @return [String] user's first name
  # @!attribute middle_name
  #   @return [String] user's middle name
  # @!attribute last_name
  #   @return [String] user's last name
  # @!attribute accept_emails
  #   @return [Boolean] whether the user accepts emails from the platform
  # @!attribute saved_searches_alerts_frequency
  #   @return [String] frequency for the saved searches alerts; valid
  #     values are: 'daily', 'weekly'
  # @!attribute language
  #   @return [String] user's language preference (two letter language
  #     code, e.g. 'en')
  # @!attribute featured
  #   @return [Boolean] whether the user is featured; could then be used
  #     to display featured users for example using the {FeaturedItemsTag}
  # @!attribute click_to_call
  #   @return [Boolean] whether the click to call functionality should be
  #     available for this user
  # @!attribute public_profile
  #   @return [Boolean] whether the profile has been marked as public

  # @!attribute tag_list
  #   @return [Array<String>] array of tags for this user
  property :tag_list

  # @!attribute email
  #   @return [String] user's email address
  property :email

  # @!attribute external_id
  #   @return [String] custom external ID for the user (if it has such
  #     an id for example in a third party database)
  property :external_id, virtual: true

  # @!attribute password
  #   @return [String] password for the user
  property :password

  validate :email_uniqueness, if: :email_changed?
  validates :email, email: true, presence: true
  validates_with PasswordValidator, if: -> { password.present? && !(new_record? && model.authentications.size.positive?) }
  def email_uniqueness
    errors.add(:email, :taken) if User.admin.with_email(email).exists?
    errors.add(:email, :taken) if external_id.blank? && User.with_email(email).exists?
  end

  model :user

  def email=(email)
    @email_changed = email != model.email
    super(email&.strip)
  end

  def email_changed?
    @email_changed
  end
end
