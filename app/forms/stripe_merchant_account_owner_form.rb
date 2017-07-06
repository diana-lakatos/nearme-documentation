# frozen_string_literal: true
class StripeMerchantAccountOwnerForm < BaseForm
  class << self
    def decorate(configuration)
      Class.new(self) do
        inject_dynamic_fields(configuration, whitelisted: [])
      end
    end
  end

  property :first_name
  validates :first_name, presence: true

  property :last_name
  validates :last_name, presence: true

  property :dob_formated
  validates :dob_formated, presence: true, date_of_birth: true

  collection :attachements, populate_if_empty: ->(fragment:, **) { model.attachements.new(file: fragment['file']) },
                            prepopulator: ->(_options) { (2 - attachements.size).times { attachements << model.attachements.build } } do
    property :file
    validates :file, presence: true
  end
  validates :attachements, length: { minimum: 2 }

  property :current_address, form: AddressForm
end
