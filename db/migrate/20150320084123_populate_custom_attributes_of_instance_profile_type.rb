class PopulateCustomAttributesOfInstanceProfileType < ActiveRecord::Migration
  def up
    # from collection_proxy.rb
    def custom_property_type_cast(value, type)
      klass = ActiveRecord::ConnectionAdapters::Column
      return [] if value.nil? && type == :array
      return nil if value.nil?
      case type
      when :string, :text        then value
      when :integer              then value.to_i rescue value ? 1 : 0
      when :float                then value.to_f
      when :decimal              then klass.value_to_decimal(value)
      when :datetime, :timestamp then klass.string_to_time(value).try(:in_time_zone)
      when :time                 then klass.string_to_dummy_time(value)
      when :date                 then klass.string_to_date(value)
      when :binary               then klass.binary_to_string(value)
      when :boolean              then klass.value_to_boolean(value)
      when :array                then value.split(',').map(&:strip)
      else value
      end
    end
    # endfrom
    Instance.find_each do |i| 
      PlatformContext.current = PlatformContext.new(i)
      instance_profile_type = InstanceProfileType.first
      User.where(instance_profile_type_id: nil).update_all(instance_profile_type_id: instance_profile_type.id)
      field_names = instance_profile_type.custom_attributes
      User.find_each do |u|
        if u.valid?
          properties_hash = {}
          field_names.each do |fn|
            properties_hash[fn.name.to_sym] = custom_property_type_cast(u[fn.name], fn.attribute_type.to_sym)
          end
          u.properties = properties_hash
          begin
            u.save!
          rescue ActiveRecord::RecordInvalid
            puts "Check UserID: #{u.id}. Reason: ActiveRecord::RecordInvalid"
          end
        end
      end
      PlatformContext.current = nil
    end
  end

  def down; end
end