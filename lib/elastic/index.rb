# frozen_string_literal: true
# FIXME: concept is not perfect
# index has one name
# index might have zero one or more aliases
# index has mappings and settings
module Elastic
  class Index
    attr_reader :alias_name, :name, :version, :body

    def initialize(name:, body:, alias_name:, version:)
      @name = name
      @alias_name = alias_name
      @version = version
      @body = body
    end
  end
end
