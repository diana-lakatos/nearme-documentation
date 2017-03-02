# frozen_string_literal: true
class SeoParams
  def self.create(params)
    new(params).to_h
  end

  def initialize(params)
    @params = params
  end

  def to_h
    slugs.each_with_object({}) { |(k, v), h| h[k] = v.tr('-', ' ').downcase }
  end

  private

  def slugs
    @params.select { |k, _v| k.to_s.start_with?('slug') }
  end
end
