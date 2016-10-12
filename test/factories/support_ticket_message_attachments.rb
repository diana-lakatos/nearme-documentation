include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :support_ticket_message_attachment, class: 'Support::TicketMessageAttachment' do
    association :ticket, factory: :support_ticket
    file { fixture_file_upload(Rails.root.join('test', 'assets', 'foobear.jpeg'), 'image/jpeg') }
    association :uploader, factory: :user
    tag 'Informational'
  end
end
