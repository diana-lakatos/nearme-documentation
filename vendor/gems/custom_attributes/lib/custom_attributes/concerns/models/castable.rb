module CustomAttributes
  module Concerns
    module Models
      module Castable
        extend ActiveSupport::Concern

        included do
          def custom_property_type_cast(value, type)
            return [] if value.nil? && type == :array
            return nil if value.nil?
            case type
            when :integer              then begin
                                              value.to_i
                                            rescue
                                              value ? 1 : 0
                                            end
            when :float                then value.to_f
            when :decimal              then ActiveRecord::Type::Decimal.new.type_cast_from_database(value)
            when :datetime, :timestamp then ActiveRecord::Type::DateTime.new.type_cast_from_database(value).try(:in_time_zone)
            when :time                 then ActiveRecord::Type::Time.new.type_cast_from_database(value)
            when :date                 then ActiveRecord::Type::Date.new.type_cast_from_database(value)
            when :binary               then ActiveRecord::Type::Binary.new.type_cast_from_database(value)
            when :boolean              then ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
            when :array                then value.split(',').map(&:strip)
            else value
            end
          end
        end
      end
    end
  end
end
