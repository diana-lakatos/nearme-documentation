# frozen_string_literal: true
module Api::Versionable
  extend ActiveSupport::Concern

  JSONAPI_CONTENT_TYPE = 'application/vnd.api+json'

  included do
    before_action :find_version, only: [:show_version, :rollback]
    before_action :set_content_type
  end

  def versions
    @versions = resource.versions.where.not(whodunnit: nil).reorder(created_at: :desc).paginate(page: params[:page])
    render json: ApiSerializer.serialize_collection(@versions.map { |v| version_to_openstruct(v) })
  end

  def show_version
    render json: ApiSerializer.serialize_object(version_to_openstruct(@version))
  end

  def rollback
    if resource.update_attributes @version.reify.serializable_hash(only: params_to_set)
      render json: ApiSerializer.serialize_object(resource, meta: { message: 'Page has been successfully restored to previous version' })
    else
      render json: ApiSerializer.serialize_errors(resource.errors)
    end
  end

  module ClassMethods
    def set_resource_method(method_name = nil, &block)
      if block_given?
        define_method(:resource, &block)
      elsif [String, Symbol].include? method_name.class
        define_method(:resource) { send(method_name) } if respond_to(method_name)
      end
    end
  end

  private

  def params_to_set
    case resource
    when Page
      %w(path content css_content)
    when InstanceView
      %w(body)
    end
  end

  def find_version
    @version = resource.versions.find params[:version_id]
    @version.define_singleton_method(:jsonapi_serializer_class_name) do
      'VersionJsonSerializer'
    end
  end

  def set_content_type
    response.headers['Content-Type'] = JSONAPI_CONTENT_TYPE
  end

  def version_to_openstruct(version)
    OpenStruct.new(
      id: version.id,
      author: User.find(version.whodunnit.to_i).try(:name),
      date: l(version.created_at, format: :long),
      show_url: url_for(action: :show_version, version_id: version.id),
      content: version.reify.try(:body),
      jsonapi_serializer_class_name: 'VersionJsonSerializer'
    )
  end
end
