class UpdateJustHalaMailers < ActiveRecord::Migration
  def up
    InstanceView.find_by(id: 2902).try(:update_attribute, :body, %Q{
<h2>Hello, {{ user.first_name }}!</h2>

<p>Your tech ninja {{ listing.name }} has submitted an invoice for your Ninjunu tech mission. Please review it and approve or decline in your dashboard. Please note that we will auto-approve this invoice after {{ listing.hours_for_guest_to_confirm_payment }} hours.
</p>
<p>
  <a class="btn" href="{{ reservation.guest_show_url }}">Take Action</a>
</p>

{% if reservation.comment != blank %}
  <p>
  Additional comment: {{ reservation.comment }}
  </p>
{% endif %}

<div class="booking-details">

  <h2>Invoice Details</h2>

  {% for line_item in reservation.transactable_line_items %}
    <div class="row">
      <strong style='display: inline-block;'>{{ line_item.name }}</strong>
      <span style="float: right;">{{ line_item.quantity }} x {{ line_item.formatted_unit_price }}</span>
    </div>
  {% endfor %}

  {% for additional_charge in reservation.additional_charges %}
    <div class="row">
      <strong style='display: inline-block;'>{{ additional_charge.name }}</strong>
      <span style="float: right;">{{ additional_charge.formatted_amount }}</span>
    </div>
  {% endfor %}

  {% if reservation.has_service_fee? %}
    <div class="row">
      <strong style='display: inline-block;'>Service fee</strong>
      <span style="float: right;">{{ reservation.service_fee }}</span>
    </div>
  {% endif %}

  <div class="row">
    <strong style='display: inline-block;'>Total</strong>
    <span style="float: right;">{{ reservation.total_price }}</span>
  </div>

</div>
                                       })


    InstanceView.find_by(id: 2903).try(:update_attribute, :body, %Q{
<h2>Hello, {{ user.first_name }}!</h2>

<p>
Ninja {{ listing.name }} has submitted an invoice. Unfortunately, we had an issue authorizing your credit card. Please update your payment information to Pay for the services rendered.
</p>
<p>
  <a class="btn" href="{{ reservation.guest_show_url }}">Update payment information</a>
</p>

{% if reservation.comment != blank %}
  <p>
  Additional comment: {{ reservation.comment }}
  </p>
{% endif %}

<div class="booking-details">

  <h2>Invoice Details</h2>

  {% for line_item in reservation.transactable_line_items %}
    <div class="row">
      <strong style='display: inline-block;'>{{ line_item.name }}</strong>
      <span style="float: right;">{{ line_item.quantity }} x {{ line_item.formatted_unit_price }}</span>
    </div>
  {% endfor %}

  {% for additional_charge in reservation.additional_charges %}
    <div class="row">
      <strong style='display: inline-block;'>{{ additional_charge.name }}</strong>
      <span style="float: right;">{{ additional_charge.formatted_amount }}</span>
    </div>
  {% endfor %}

  {% if reservation.has_service_fee? %}
    <div class="row">
      <strong style='display: inline-block;'>Service fee</strong>
      <span style="float: right;">{{ reservation.service_fee }}</span>
    </div>
  {% endif %}

  <div class="row">
    <strong style='display: inline-block;'>Total</strong>
    <span style="float: right;">{{ reservation.total_price }}</span>
  </div>

</div>

    })

  end

  def down
  end
end
