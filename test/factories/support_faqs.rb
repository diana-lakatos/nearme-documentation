FactoryGirl.define do
  factory :support_faq, class: 'Support::Faq' do
    question 'Do you use Redis?'
    answer 'Depends.'
  end
end
