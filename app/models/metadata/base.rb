# Base class for handling metadata.
#
# This encapsulates logic for handling 'metadata'.
#
#
# Usage:
#
#   Assume you want to keep metadata in Salad model to know what apples it contains. First define has_metadata in a model and add
#   <column_name> to db as :text, for example via command:
#
#   rails g migration AddMetadataToSalad metadata:text
#
#   sample definition of corresponding model:
#
#   class Salad < ActiveRecord::Base
#     has_many :apples
#
#     # defaults are: column_name: "metadata", :observer_class => Metadata::SaladMetadata, :accessors => [], :without_db_column => false
#     has_metadata :accessors => [ :apples_names ]
#
#   end
#
#   Then define observer class that was specified via key
#
#   class Metadata::SaladMetadata
#     extend ActiveSupport::Concern
#
#     def populate_calories!
#       # use update_metadata method which is provided by Metadata::Base module. It takes array of hashes as argument and
#       # is responsible for persisting updated metadata
#       update_metadata({apples_names: apples.pluck(:name)})
#     end
#   end
#
#   You should now update apples_names whenever apple is added to salad, removed fro it or changed_name. The suggested way is to use Metadata::Base again.
#
#   class Apple < ActiveRecord::Base
#     belongs_to :salad
#     # we don't need to persist anything in apple so we don't have metadata column in db
#     has_metadata :without_db_column => true
#   end
#
#   And then define logic for updating salad - basically after_commit callbacks
#
#   class Metadata::AppleMetadata
#     extend ActiveSupport::Concern
#
#      after_commit :salad_populate_calories!, :if => lambda { |salad| salad.should_populate_calories? }
#      delegate :populate_calories!, :to => :salad, :prefix => true
#
#      def should_populate_calories?
#        # we want to trigger on create, destroy and updating name
#        %(id deleted_at name).any? do |attr|
#          # metadata_relevant_attribute_changed? is method defined by Metadata::Base
#          metadata_relevant_attribute_changed?(attr)
#        end
#      end
#   end
#
#   That's it. Now in views you can use
#
#   @salad.apples_names # => [ name1, name2, name3 .. ]
#
#   If you haven't specified accessor, you can still access it via
#
#   @salad.metadata["apples_names"] # => [ name1, name2, name3 .. ]
#
#  Note:
#    You might specify more than one column in db, just ensure you pass column_name option to at least one. Of course you need to have corresponding
#    column in database as :text
#
#    class MetadataContainer < ActiveRecord::Base
#      has_metadata :column_name => "some_metadata"
#      has_metadata :column_name => "some_other_metadata"
#      has_metadata :column_name => "another_metadata"
#    end
module Metadata::Base
  class InvalidArgumentError < StandardError; end
  extend ActiveSupport::Concern

  included do

    def metadata_relevant_attribute_changed?(attr)
      previous_changes.keys.include?(attr) && previous_changes[attr].first != previous_changes[attr].last
    end

    def self.has_metadata(options = {})
      options.reverse_merge!({
        column_name: "metadata",
        without_db_column: false,
        scope_to_instance: false,
        accessors: []
      })

      metadata_column = options[:column_name]
      include options.fetch(:observer_class, "Metadata::#{self.name}#{metadata_column.capitalize}").to_s.constantize

      unless options[:without_db_column]

        class_eval <<-EOV,  __FILE__, __LINE__

          store :#{metadata_column}

          def update_#{metadata_column}(*args)
            args.each do |arg|
              raise Metadata::Base::InvalidArgumentError.new("#{metadata_column} must be Hash") unless arg.kind_of?(Hash)
              arg.each do |key, value|
                self.#{metadata_column}[key] = value
              end
            end
            tmp_#{metadata_column} = #{metadata_column}
            update_columns(#{metadata_column}: self.#{metadata_column}, updated_at: Time.now)
            self.touch unless new_record?
            self.#{metadata_column} = tmp_#{metadata_column}
          end

          def update_instance_#{metadata_column}(*args)
            # We do this to allow changes in admin to users
            # where we don't have an instance_id; that's mostly
            # deleting objects; for super admins data may not be set
            # for the right instance under certain complex operations
            # but that's OK as for now we're mostly using the workaround
            # for allowing the deletion of objects
            instance_id_for_metadata = get_instance_id_for_metadata
            return nil if instance_id_for_metadata.blank?

            args.each do |arg|
              raise Metadata::Base::InvalidArgumentError.new("#{metadata_column} must be Hash") unless arg.kind_of?(Hash)
              self.#{metadata_column}[instance_id_for_metadata] ||= {}
              arg.each do |key, value|
                self.#{metadata_column}[instance_id_for_metadata][key] = value
              end
            end

            tmp_#{metadata_column} = #{metadata_column}
            update_columns(#{metadata_column}: self.#{metadata_column}, updated_at: Time.zone.now)
            self.touch unless new_record?
            self.#{metadata_column} = tmp_#{metadata_column}
          end

          def get_instance_#{metadata_column}(attr)
            instance_id_for_metadata = get_instance_id_for_metadata
            return nil if instance_id_for_metadata.blank?

            return nil if #{metadata_column}.nil? || #{metadata_column}[instance_id_for_metadata].nil?
            #{metadata_column}[instance_id_for_metadata][attr]
          end

          def get_instance_id_for_metadata
            (PlatformContext.current.try(:instance).try(:id) || self.try(:instance_id)).to_s
          end
        EOV

      end

      if options[:accessors].any?
        class_eval <<-EOV
          store_accessor :#{metadata_column}, :#{options[:accessors].join(", :")}
        EOV
      end
    end
  end
end
