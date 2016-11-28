# frozen_string_literal: true
class UserForm < BaseForm
  include Reform::Form::ActiveModel::ModelReflections
  class << self
    def decorate(configuration)
      Class.new(self) do
        if (buyer_profile_configuration = configuration.delete(:buyer_profile)).present?
          validation = buyer_profile_configuration.delete(:validation)
          validates :buyer_profile, validation if validation.present?
          property :buyer_profile, form: UserProfileForm.decorate(buyer_profile_configuration),
                                   populate_if_empty: :populate_user_profile!,
                                   prepopulator: -> (options) { self.buyer_profile ||= model.build_buyer_profile(instance_profile_type: PlatformContext.current.instance.buyer_profile_type) }
        end
        if (seller_profile_configuration = configuration.delete(:seller_profile)).present?
          validation = seller_profile_configuration.delete(:validation)
          validates :seller_profile, validation if validation.present?
          property :seller_profile, form: UserProfileForm.decorate(seller_profile_configuration),
                                    populate_if_empty: :populate_user_profile!,
                                    prepopulator: -> (options) { self.seller_profile ||= model.build_seller_profile(instance_profile_type: PlatformContext.current.instance.seller_profile_type) }
        end
        if (default_profile_configuration = configuration.delete(:default_profile)).present?
          validation = default_profile_configuration.delete(:validation)
          validates :default_profile, validation if validation.present?
          property :default_profile, form: UserProfileForm.decorate(default_profile_configuration),
                                     populate_if_empty: :populate_user_profile!,
                                     prepopulator: -> (options) { self.default_profile ||= model.build_default_profile(instance_profile_type: PlatformContext.current.instance.default_profile_type) }
        end
        if (transactables_configuration = configuration.delete(:transactables)).present?
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
        if (current_address_configuration = configuration.delete(:current_address)).present?
          property :current_address, form: AddressForm.decorate(current_address_configuration),
                                     populate_if_empty: Address,
                                     prepopulator: ->(*) { self.current_address ||= Address.new }
        end
        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
    end
  end

  include Devise::Models::UserValidatable
  property :tag_list
  property :email
  property :external_id, virtual: true
  property :password
  property :password_confirmation


  validate :base_email_validation, if: :email_changed?
  def base_email_validation
    errors.add(:email, :blank) if email.blank?
    errors.add(:email, :taken) if User.admin.where(email: email).exists?
    errors.add(:email, :taken) if User.where(email: email).exists? if external_id.blank?
  end

  def populate_user_profile!(as:, **)
    model.send(:"get_#{as}")
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
