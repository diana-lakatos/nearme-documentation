Spree::Store.class_eval do
  include Spree::Scoper

  def self.current(domain = nil)
    instance_id = PlatformContext.current.try(:instance).try(:id)
    current_store = Spree::Store.find_by(instance_id: instance_id) if instance_id
    current_store ||= Store.by_url(domain).first if domain
  end
end
