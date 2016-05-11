Given /^transactable type skips payment authorization initially$/ do
  TransactableType.update_all(hours_for_guest_to_confirm_payment: 24)
  ReservationType.find_each{ |rt| rt.update!(skip_payment_authorization: true) }
end

When /^I fill in a time log fields$/ do
  fill_in "reservation[transactable_line_items_attributes][0][name]", with: "First time log"
  all(:css, ".transactable-line-items .nested-fields .reservation_transactable_line_items_name input").last.set("Second time log")
  all(:css, ".transactable-line-items .nested-fields .reservation_transactable_line_items_quantity input").last.set("5.0")
  all(:css, ".transactable-line-items .nested-fields .reservation_transactable_line_items_quantity input").last.trigger("change")
  assert_equal "$50.00", all(:css, ".transactable-line-items .nested-fields .sub-total").last.text
end

When /^I fill in a additional charge fields$/ do
  # fill_in "reservation[transactable_line_items_attributes][0][description]", with: "Additional cost"
  first(:css, ".additional-line-items .nested-fields .reservation_additional_line_items_name input").set("Additional cost")
  first(:css, ".additional-line-items .nested-fields input.price-input").set("100")
  first(:css, ".additional-line-items .nested-fields input.price-input").trigger('change')
  assert_equal "$100.00", first(:css, ".additional-line-items .nested-fields .sub-total").text
end

Then /^I should see correct Total cost of "([^"]*)"$/ do |amount|
  assert_equal amount, page.find(".total .amount").text
end

And /^I delete last additional charge$/ do
  all(:css, ".additional-line-items .nested-fields .remove_fields").last.click
end

And /^reservation should have all data stored$/ do
  reservation = Reservation.last
  assert_equal 2, reservation.transactable_line_items.size
  assert_equal "Second time log", reservation.transactable_line_items.order("created_at DESC").first.name
  assert_equal 100_00, reservation.additional_line_items.first.total_price_cents
end

