class CreateOrderItemUpdatedEmail < ActiveRecord::Migration
  def up
    @instance = Instance.find_by_id(195)
    return if @instance.blank?
    @instance.set_context!
    Utils::DefaultAlertsCreator::OrderItemCreator.new.create_notify_lister_updated_order_item!
    path = 'order_item_mailer/notify_lister_updated_order_item'
    body = File.read(File.join(Rails.root, 'lib', 'tasks', 'uot', 'templates', 'mailers', path + '.html.liquid'))
    iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'html', partial: false).first_or_initialize
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.body = body
    iv.save!

    iv = InstanceView.where(instance_id: @instance.id, view_type: 'email', path: path, handler: 'liquid', format: 'text', partial: false).first_or_initialize
    iv.body = ActionView::Base.full_sanitizer.sanitize(body)
    iv.locales = Locale.all
    iv.transactable_types = TransactableType.all
    iv.save!
  end

  def down
  end
end
