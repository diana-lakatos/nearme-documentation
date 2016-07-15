class ReverseProxyLink < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :domain

  validates_presence_of :use_on_path, :destination_path, :name

  def jsonapi_serializer_class_name
    'ReverseProxyLinkJsonSerializer'
  end

  def to_liquid
    @reverse_proxy_link_drop ||= ReverseProxyLinkDrop.new(self)
  end

end

