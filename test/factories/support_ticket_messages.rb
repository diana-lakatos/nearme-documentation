FactoryGirl.define do
  factory :support_ticket_message, class: 'Support::TicketMessage' do
    association :ticket, factory: :support_ticket
    full_name 'My Name'
    email 'my@examle.org'
    subject 'Subject of message'
    message 'I have a lot of questions. Where to start.'
  end
end
