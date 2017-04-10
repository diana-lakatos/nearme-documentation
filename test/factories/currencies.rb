# frozen_string_literal: true
FactoryGirl.define do
  factory :currency do
    symbol '$'
    priority 1
    symbol_first true
    thousands_separator ','
    html_entity '$'
    decimal_mark '.'
    name 'United States Dollar'
    subunit_to_unit 100
    exponent 2.0
    iso_code 'USD'
    iso_numeric 840
    subunit 'Cent'

    factory :currency_us do
    end

    factory :currency_pl do
      symbol 'zł'
      priority 100
      symbol_first false
      thousands_separator ' '
      html_entity 'z&#322;'
      decimal_mark ','
      name 'Polish Złoty'
      subunit_to_unit 100
      exponent 2.0
      iso_code 'PLN'
      iso_numeric 985
      subunit 'Grosz'
    end

    factory :currency_aud do
      symbol '$'
      priority 4
      html_entity '$'
      name 'Australian Dollar'
      iso_code 'AUD'
      iso_numeric 36
    end

    factory :currency_nzd do
      symbol '$'
      priority 100
      symbol_first true
      thousands_separator ','
      html_entity '$'
      decimal_mark '.'
      name 'New Zealand Dollar'
      subunit_to_unit 100
      exponent 2.0
      iso_code 'NZD'
      iso_numeric 554
      subunit 'Cent'
      smallest_denomination 1
    end

    factory :currency_jpy do
      symbol '¥'
      priority 6
      symbol_first true
      thousands_separator ','
      html_entity '&#x00A5;'
      decimal_mark '.'
      name 'Japanese Yen'
      subunit_to_unit 1
      exponent 0.0
      iso_code 'JPY'
      iso_numeric 392
      subunit nil
      smallest_denomination 1
    end
  end
end
