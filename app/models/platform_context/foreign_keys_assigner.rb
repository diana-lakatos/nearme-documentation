#  Module responsible for setting PlatformContext for new records
#
#  It makes sure that all new records will have correctly populated instance_id/domain_id/partner_id/company_id
#  based on PlatformContext.current. It also makes sure that user won't be able to fake any of these keys.
#
#  Usage:
#
#  add auto_set_platform_context to model, for example
#
#  Transactable.rb
#  auto_set_platform_context
#
#  Method takes as argument options hash, with keys:
#  :allow_nil - it's an array of keys which can be null, for example :allow_nil => [:instance_id]. Default is empty array. Any keys specified
#               in allow_nil won't be populated by default. [ maybe better name would be skip_* or something like this ]
#
module PlatformContext::ForeignKeysAssigner
  extend ActiveSupport::Concern

  included do
    def self.auto_set_platform_context(options = {})
      if self.table_exists?
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #{'validates_presence_of :instance_id' if !options[:allow_nil].try(:include?, :instance_id) && column_names.include?('instance_id')}

          before_validation do
            if !self.persisted? && !self.marked_for_destruction? && !PlatformContext.current.nil?
              #{'self.instance_id = PlatformContext.current.instance.id' if column_names.include?('instance_id') && !options[:allow_nil].try(:include?, :instance_id)}
              #{'self.domain_id = PlatformContext.current.domain.try(:id)' if column_names.include?('domain_id')}
              #{'self.partner_id = PlatformContext.current.partner.try(:id)' if column_names.include?('partner_id')}
              #{'if PlatformContext.current.white_label_company' if column_names.include?('company_id') || column_names.include?('listings_public')}
                #{"self.company_id = PlatformContext.current.white_label_company.id\n" if column_names.include?('company_id')}
                #{"self.listings_public = PlatformContext.current.white_label_company.listings_public\n" if column_names.include?('listings_public')}
              #{'end' if column_names.include?('company_id') || column_names.include?('listings_public')}
            else
              true
            end
          end
        RUBY
      end
    end
  end
end
