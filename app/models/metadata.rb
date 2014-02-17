module Metadata
  extend ActiveSupport::Concern
  class InvalidArgumentError < StandardError; end

  included do

    serialize :metadata, JSON

    def update_metadata(*args)
      args.each do |arg|
        raise InvalidArgumentError.new("Metadata is in JSON format, only hashes are available") unless arg.kind_of?(Hash)
        metadata.merge!(arg)
      end
      update_column(:metadata, metadata.to_json)
      self.touch
      self.metadata = JSON.parse(metadata) if metadata.is_a?(String)
    end

    def metadata_relevant_attribute_changed?(attr)
      previous_changes.keys.include?(attr) && previous_changes[attr].first != previous_changes[attr].last
    end

    alias :not_metadata_method_missing :method_missing
    def method_missing(method, *args, &block)  
      if method.to_s.include?('_metadata')
        self.metadata[method.to_s.gsub('_metadata', '')]
      else
        not_metadata_method_missing(method, *args, &block)
      end
    end

  end

end
