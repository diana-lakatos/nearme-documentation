Given /^transactable type skips payment authorization initially$/ do
  TransactableType.update_all(skip_payment_authorization: true, hours_for_guest_to_confirm_payment: 24)
end

When /^I fill in a time log fields$/ do
  fill_in "reservation[periods_attributes][0][description]", with: "First time log"
  all(:css, ".periods .nested-fields .reservation_periods_description input").last.set("Second time log")
  all(:css, ".periods .nested-fields .reservation_periods_hours input").last.set("5.0")
  all(:css, ".periods .nested-fields .reservation_periods_hours input").last.trigger("change")
  assert_equal "$50.00", all(:css, ".periods .nested-fields .sub-total").last.text
end

When /^I fill in a additional charge fields$/ do
  fill_in "reservation[periods_attributes][0][description]", with: "Additional cost"
  first(:css, ".additional-charges .nested-fields .reservation_additional_charges_name input").set("Additional cost")
  first(:css, ".additional-charges .nested-fields input.price-input").set("100")
  first(:css, ".additional-charges .nested-fields input.price-input").trigger('change')
  assert_equal "$100.00", first(:css, ".additional-charges .nested-fields .sub-total").text
end

Then /^I should see correct Total cost of "([^"]*)"$/ do |amount|
  assert_equal amount, page.find(".total .amount").text
end

And /^I delete last additional charge$/ do
  all(:css, ".additional-charges .nested-fields .remove_fields").last.click
end

And /^reservation should have all data stored$/ do
  reservation = Reservation.last
  assert_equal 2, reservation.periods.size
  assert_equal "Second time log", reservation.periods.order("created_at DESC").first.description
  assert_equal 100_00, reservation.additional_charges.first.amount_cents
end

