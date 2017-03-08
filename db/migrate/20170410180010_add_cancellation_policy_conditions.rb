class AddCancellationPolicyConditions < ActiveRecord::Migration
  def up
    create_table :cancellation_policy_conditions, force: :cascade do |t|
      t.integer  :instance_id
      t.text     :name
      t.text     :query
      t.text     :variables
      t.text     :validators
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :deleted_at
    end

    CancellationPolicyCondition.reset_column_information

    puts "Migrating instances:"
    Instance.all.each do |instance|
      instance.set_context!
      puts "- [#{instance.id}] #{instance.name}"

      [
        {
          name: 'Order not confirmed',
          query: "order.state != 'confirmed'",
          validators: [
            { name: 'order', attributes: { state: 'cancelled_by_guest' }, result: 'true' },
            { name: 'order', attributes: { state: 'confirmed' }, result: '' },
          ]
        },
        {
          name: 'Order confirmed',
          query: "order.state == 'confirmed'",
          validators: [
            { name: 'order', attributes: { state: 'cancelled_by_guest' }, result: '' },
            { name: 'order', attributes: { state: 'confirmed' }, result: 'true' },
          ]
        },
        {
          name: 'Order not archived',
          query: "order.archived_at == null",
          validators: [
            { name: 'order', attributes: { archived_at: Time.now.to_s }, result: '' },
            { name: 'order', attributes: { archived_at: nil }, result: 'true' },
          ]
        },

        {
          name: 'Order is cancelled by guest',
          query: "order.state == 'cancelled_by_guest'",
          validators: [
            { name: 'order', attributes: { state: 'cancelled_by_guest'}, result: 'true' },
            { name: 'order', attributes: { state: 'cancelled_by_host'}, result: '' }
          ]
        },

        {
          name: 'Order is cancelled by host',
          query: "order.state == 'cancelled_by_host'",
          validators: [
            { name: 'order', attributes: { state: 'cancelled_by_guest'}, result: '' },
            { name: 'order', attributes: { state: 'cancelled_by_host'}, result: 'true' }
          ]
        },

        {
          name: 'Booking started',
          variables: [
            "{% assign starts_at = order.starts_at | date: '%s' %}",
            "{% assign starts_at_size = starts_at | size %}",
            "{% assign order_start_difference = 'now' | date: '%s' | minus: starts_at %}",
          ],
          query: "starts_at_size != 0 and order_start_difference > 0",
          validators: [
            { name: 'order', attributes: { starts_at: (Time.now + 1.day).to_s }, result: '' },
            { name: 'order', attributes: { starts_at: nil }, result: '' },
            { name: 'order', attributes: { starts_at: (Time.now - 1.day).to_s}, result: 'true' },
          ]
        },

        {
          name: 'Booking did not start',
          variables: [
            "{% assign starts_at = order.starts_at | date: '%s' %}",
            "{% assign starts_at_size = starts_at | size %}",
            "{% assign difference = 'now' | date: '%s' | minus: starts_at %}",
          ],
          query: "starts_at_size != 0 and difference < 0",
          validators: [
            { name: 'order', attributes: { starts_at: (Time.now - 1.day).to_s }, result: '' },
            { name: 'order', attributes: { starts_at: nil }, result: '' },
            { name: 'order', attributes: { starts_at: (Time.now + 1.day).to_s}, result: 'true' },
          ]
        },

        {
          name: 'More than a day to booking start',
          query: "starts_at_size != 0 and difference > 0",
          variables: [
            "{% assign tomorrow = 'now' | date: '%s' | plus: 86400 | times: 1 %}",
            "{% assign starts_at = order.starts_at | date: '%s' %}",
            "{% assign starts_at_size = starts_at | size %}",
            "{% assign difference = starts_at | minus: tomorrow %}"
          ],
          validators: [
            { name: 'order', attributes: { starts_at: (Time.now + 25.hours).to_s}, result: 'true' },
            { name: 'order', attributes: { starts_at: (Time.now + 23.hours).to_s}, result: '' },
            { name: 'order', attributes: { starts_at: nil}, result: '' },
          ]
        },

        {
          name: 'Deliveries can be cancelled',
          query: 'deliveries_count > 0 or cancellable',
          variables: [
            "{% assign deliveries_count = order.deliveries | size %}",
            "{% assign cancellable = true %}{% for delivery in order.deliveries %}{% if cancellable %}{% assign cancellable = delivery.cancellable? %}{% endif %}{% endfor %}"
          ],
          validators: [
            { name: 'order', attributes: { deliveries: []}, result: 'true' },
          ]
        },
      ].each do |attributes|
        CancellationPolicyCondition.create(attributes)
      end

      def down
        drop_table :cancellation_policy_conditions
      end

    end
  end
end
