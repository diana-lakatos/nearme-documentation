#  Module responsible for adding inheritance of specified columns
#
#  It helps in situation when for some reason we want to make some data redundant. For example, if model A has many
#  models B, we might want to have in model B duplicated column. This might be the case for foreign keys for example,
#  if model A has creator_id and model B does not have it, then to get all models B that belong to user, we will have
#  to use JOIN model A to get this info. If we just made creator_id redundant, meaning model B would have not only a_id
#  but also creator_id, we can make just a simple query without JOIN.
#
#  Model provides two methods: inherits_columns_from_association() for inheriting values from parent when they are created,
#  and notify_associations_about_column_update() to make sure that our data is consistent, so when parent's values are
#  updated, all children will also be updated.
#
#  Usage:
#
#  inherits_columns_from_association(columns, parent_association)
#
#    Method takes two required arguments:
#    columns            - is either single symbol of column to be inherited ( f.e. :creator_id) or
#                       array of columns ( f.e. [:creator_id, :updated_by_id] ).
#    parent_association - is symbol used in belongs_to ( f.e if model B belongs_to :a, then it's :a).
#
#    Example:
#      # location.rb
#      class Location < ActiveRecord::Base
#       belongs_to :company
#       inherits_columns_from_association([:creator_id, :instance_id], :company)
#      end
#
#     this will add before_create filters that will populate creator_id and instance_id with
#     values from company.creator_id and company.instance_id
#
#     note:
#     There is a know caveat that if filter returns false, then transaction will be rollback. Sometimes this
#     can happen unintentionally, for example if we want to inherit boolean column which has value false. This
#     module takes care of this, and explicitly returns nil.
#
#  notify_associations_about_column_update(associations, columns)
#
#    Method takes two required arguments:
#    associations - is symbol or array of symbols used in has_many ( f.e if model A has_many :b, then it's :b).
#    columns      - is either single symbol of column to be observed ( f.e. :creator_id) or
#                   array of columns ( f.e. [:creator_id, :updated_by_id] ) - if they are changed, all associations
#                   will be updated with the new value via updated_column method (to skip callbacks)
#
#    Example:
#      # company.rb
#      class Company < ActiveRecord::Base
#       has_many :locations
#       notify_associations_about_column_update(:locations, [:creator_id, :instance_id])
#      end
#
#     this will add after_update filters that will make sure that all children locations will
#     have creator_id and instance_id updated if they change

module ColumnsObserver
  class InvalidArgumentError < StandardError; end
  extend ActiveSupport::Concern

  included do
    def self.inherits_columns_from_association(columns, associations, callback_name = 'before_create')
      return unless self.table_exists?
      inherits_columns_from_association_string = "#{callback_name}(on: :create) do \n"
      [columns].flatten.each do |column|
        next unless column_names.include?(column.to_s)
        [associations].flatten.each do |association|
          inherits_columns_from_association_string += "self.#{column} ||= #{association}.#{column} if #{association}\n"
        end
      end
      class_eval %( #{inherits_columns_from_association_string + "nil\nend"} )
    end

    def self.notify_associations_about_column_update(associations, columns)
      return unless self.table_exists?
      notify_associations_about_column_update = "after_update do\n"
      [columns].flatten.each do |column|
        fail ColumnsObserver::InvalidArgumentError.new("Invalid argument, #{name} does not contain column #{column}") unless column_names.include?(column.to_s)
        [associations].flatten.each do |association|
          notify_associations_about_column_update += "self.#{association}.reload.with_deleted.update_all(['#{column} = ?', self.#{column}]) if self.#{column}_changed?\n"
        end
      end
      class_eval %( #{notify_associations_about_column_update + 'end'} )
    end
  end
end
