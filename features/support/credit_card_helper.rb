module CreditCardHelper
  def select_add_new_cc
    # This has to happen only in capybara. Normally its handled by javascript in browser
    page.execute_script("$('.payment-source-option-select input[type=radio][value=new_credit_card]').attr('checked', true).trigger('change')")
    page.should_not have_css('.nm-new-credit-card-form.hidden')
  end

  def fill_new_credit_card_fields
    fill_in '* First Name', with: 'FirstName', visible: false
    fill_in '* Last Name', with: 'LastName', visible: false
    select('12', from: '* Expiration date: Month', visible: false)
    select('2024', from: '* Expiration date: Year', visible: false)
    fill_in '* Security code', with: '411', visible: false

    # note we provide too long CC number on purpose - jquery.payment should validate the input and remove unnecessary 555
    page.execute_script("$('[data-stripe=number]').val('4242 4242 4242 4242 555').trigger('change').trigger('blur')")
  end
end

World(CreditCardHelper)
