module CustomAttributes
  module Accessors
    extend ActiveSupport::Concern

    included do

      def set_custom_attributes(store_accessor_name)
        metaclass = class << self; self; end
        obj = self
        hstore_attributes = custom_attributes_names_types_hash.reject { |k, v| k.include?('_price_cents') }
        metaclass.class_eval do
          hstore_attributes.each do |key, type|
            unless obj.respond_to?(key)
              define_method("#{key}") do
                self.send("#{store_accessor_name}").send(key)
              end

              if type.to_sym == :boolean
                define_method("#{key}?") do
                  self.send("#{store_accessor_name}").send(key)
                end
              end

              unless obj.respond_to?("#{key}=")
                define_method("#{key}=") do |val|
                  self.send("#{store_accessor_name}").send("#{key}=", val)
                end
              end
            end
          end
        end
        @custom_attributes_set = true
      end

    end

  end
end

