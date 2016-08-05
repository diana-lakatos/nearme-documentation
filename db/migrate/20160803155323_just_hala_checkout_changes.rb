class JustHalaCheckoutChanges < ActiveRecord::Migration
  def up
    @instance = Instance.find_by(id: 175)
    return true if @instance.nil?

    @instance.set_context!

    ch = @instance.theme.content_holders.find_by(
      name: 'Just Hala CSS'
    )

    ch.update!({
      content: "<link rel='stylesheet' media='screen' href='https://d2rw3as29v290b.cloudfront.net/instances/175/uploads/ckeditor/attachment_file/data/2710/just_hala.css'>"
    })

     iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'checkout/sidebar',
      partial: true
    ).first_or_initialize

    iv.update!({
      transactable_types: TransactableType.all,
      body: %Q{
<h3>Simple steps</h3>
<p>Here's what happens next</p>

<ol>
<li>The Ninja will get in touch with you within 30 minutes. Please keep your mobile phone on or watch your Ninjunu mailbox.</li>

<li>Your technical issues will be resolved.</li>

<li>Your credit card will be charged after the mission is completed.</li>
</ol>

<h3>Need Help?</h3>
<p><strong>Call: {{ platform_context.phone_number }}</strong></p>
      },
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all
    })

     iv = InstanceView.where(
      instance_id: @instance.id,
      path: 'checkout/summary',
      partial: true
    ).first_or_initialize

    iv.update!({
      transactable_types: TransactableType.all,
      format: 'html',
      handler: 'liquid',
      partial: true,
      view_type: 'view',
      locales: Locale.all,
      body: %Q{
<h1>Book a Tech Mission</h1>

<h2>{{ @order.total_units_text | titleize }}</h2>

{% if @order.action_hourly_booking? %}
  <p>{{ @order.hourly_summary }}</p>
{% else %}
  <div class='selected-dates-summary'>
    <hr class='thin'>
    {{ @order.dates_summary_with_hr }}
  </div>
{% endif %}

<hr class='thin'>

<table class="payment-summary">
  <thead>
    <th scope="col">Ninja</th>

    {% if @order.included_tax? %}
      <th scope="col">Net</th>
      <th scope="col">Tax</th>
    {% endif %}

    <th scope="col">Price</th>

    {% if @order.additional_tax? %}
      <th scope="col">Tax</th>
      <th scope="col">Gross</th>
    {% endif %}

    <th scope="col">Qty</th>
    <th scope="col">Total</th>
  </thead>
  <tbody>
    {% for item in @order.line_items %}
      <tr data-line-item-class="{{ item.object.class.name.demodulize }}">
        <td>{{ item.name }}</td>

        {% if @order.included_tax? %}
          <td>{{ item.net_price | price_with_cents_with_currency }}</td>
          <td>{{ item.included_tax_total_rate }}%</td>
        {% endif %}

        <td>{{ item.formatted_unit_price }}</td>

        {% if @order.additional_tax? %}
          <td>{{ item.additional_tax_total_rate }}%</td>
          <td>{{ item.gross_price | price_with_cents_with_currency }}</td>
        {% endif %}
        <td>{{ item.quantity }}</td>
        <td>{{ item.total_price | price_with_cents_with_currency }}</td>
      </tr>
    {% endfor %}
    <tr>
      <td colspan="{% if @order.included_tax? || @order.additional_tax? %}4{% else %}2{% endif %}"></td>
      <th headers="summary-total">Total</th>
      <td id="summary-total">{{ @order.total_amount | price_with_cents_with_currency }}</td>
    </tr>
  </tbody>
</table>
      }
    })


  end
end
