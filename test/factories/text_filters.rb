FactoryGirl.define do
  factory :text_filter do
    sequence(:name) { |n| "Text Filter #{n}" }
    regexp 'regexp'
    replacement_text '[FILTERED]'

    factory :text_filter_email do
      regexp '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}'
      flags Regexp::IGNORECASE
      replacement_text '[EMAIL FILTERED]'
    end

    factory :text_filter_10phone do
      regexp '\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})'
      replacement_text '[10PHONE FILTERED]'
    end

    factory :text_filter_7phone do
      regexp '(?:\(?([0-9]{3})\)?[-. ]?)?([0-9]{3})[-. ]?([0-9]{4})'
      replacement_text '[7PHONE FILTERED]'
    end
  end
end
