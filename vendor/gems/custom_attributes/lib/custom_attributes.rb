require "custom_attributes/engine"
require "custom_attributes/version"
require "custom_attributes/concerns/models/castable"
require "custom_attributes/has_custom_attributes"
require "custom_attributes/acts_as_custom_attributes_set"
require "custom_attributes/collection_proxy"
require "custom_attributes/custom_validator"
require "custom_attributes/concerns/models/custom_attribute"

module CustomAttributes
  ActiveSupport.on_load(:active_record) do
    include CustomAttributes::HasCustomAttributes
    include CustomAttributes::ActsAsCustomAttributesSet
  end
end
