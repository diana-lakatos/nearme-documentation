class AddInstanceViewToLocaldriva < ActiveRecord::Migration
  def up
    @instance = Instance.find_by(id: 211)
    return unless @instance
    @instance.set_context!

    body = <<-EOS
      {% assign form_object = f %}
      {% assign transactable_starts_at = f.object.transactable.properties.trip_start_date  %}
      {% input starts_at, as: hidden, input_html-value: @transactable_starts_at %}
    EOS

    iv = InstanceView.find_or_initialize_by(
      instance_id: @instance.id,
      view_type: 'view',
      partial: true,
      path: 'checkout/custom',
      format: 'html',
      handler: 'liquid'
    )
    iv.locales << Locale.find_by(code: 'en')
    iv.body = body
    iv.save!
  end

  def down
  end
end
