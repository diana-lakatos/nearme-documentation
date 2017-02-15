module CreditCardHelper
  def open_cc_accordion
    # Accordion is present only if there is more than 1 payment method.
    # Would be nice to have different steps for those, but reservations_steps:262 is called
    # in 2^8 places and life of frontend developer is too short to fix it.
    # TODO: FIX
    if page.has_link?('Credit Card')
      click_on('Credit Card')
    end
  end

  def select_add_new_cc
    # This has to happen only in capybara. Normally its handled by javascript in browser
    page.execute_script("$('.payment-source-option-select input[type=radio][value=new_credit_card]').attr('checked', true).trigger('change')")
    page.should_not have_css('.nm-new-credit-card-form.hidden')
  end

  def fill_new_credit_card_fields
    fill_in '* First Name', with: 'FirstName'
    fill_in '* Last Name', with: 'LastName'
    select '12', from: '* Expiration date: Month'
    select '2024', from: '* Expiration date: Year'
    fill_in '* Security code', with: '411'

    # note we provide too long CC number on purpose - jquery.payment should validate the input and remove unnecessary 555
    page.execute_script("$('[data-stripe=number]').val('4242 4242 4242 4242 555').trigger('change').trigger('blur')")
  end
end

World(CreditCardHelper)
