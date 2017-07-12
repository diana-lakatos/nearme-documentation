module MerchantAccount::Concerns::DataAttributes
  extend ActiveSupport::Concern

  included do
    serialize :data, Hash

    self::ATTRIBUTES.each do |attr|
      define_method attr do
        data.stringify_keys[attr]
      end

      define_method "#{attr}=" do |val|
        attribute_will_change!(attr)
        data[attr] = val
      end
    end
  end
end
