FactoryGirl.define do
  factory :support_ticket, class: 'Support::Ticket' do
    target { PlatformContext.current.instance }
    ignore do
      messages_count 1
    end

    after(:create) do |t, e|
      create_list(:support_ticket_message, e.messages_count, ticket: t)
    end

    factory :support_ticket_with_user do
      user
    end
  end
end
