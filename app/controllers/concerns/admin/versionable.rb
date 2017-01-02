# frozen_string_literal: true
module Admin::Versionable
  extend ActiveSupport::Concern

  included do
    before_action :find_version, only: [:show_version, :rollback]
  end

  def versions
    @versions = resource.versions.where.not(whodunnit: nil).reorder(created_at: :desc).paginate(page: params[:page])

    render template: 'admin/theme/versions/index'
  end

  def show_version
    render template: 'admin/theme/versions/show'
  end

  def rollback
    if resource.update_attributes @version.reify.serializable_hash(only: params_to_set)
      redirect_url = respond_to?(:show) ? { action: :show, id: resource.id } : { action: :index }
      redirect_to redirect_url, notice: 'Page has been successfully restored to previous version'
    else
      flash[:error] = 'Unable to restore page to previous version'
      render :show_version
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
  end
end
