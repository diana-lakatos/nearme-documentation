# frozen_string_literal: true
require 'test_helper'

class NotificationsConnectedWithFormTest < ActionDispatch::IntegrationTest
  setup do
    @admin = FactoryGirl.create(:user, first_name: 'Admin', password: 'password')
    @user = FactoryGirl.create(:user, first_name: 'John', password: 'password',
                                      mobile_number: '+48123456789', email: 'user@example.com')
    post_via_redirect '/users/sign_in', user: { email: @user.email, password: @user.password }
  end

  should 'trigger email notification alerts with the form' do
    assert_difference 'ActionMailer::Base.deliveries.size' do
      put_via_redirect "/api/users/#{@user.id}", form: { first_name: 'Maciek' },
                                                 form_configuration_id: form_configuration_with_email_notification.id
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal 'Maciek', @user.reload.first_name
    assert_response :success
    assert_contains "Your id is #{@user.id}", mail.html_part.body
    assert_contains 'maciek@example.com', mail.from
    assert_contains 'user@example.com', mail.to
    assert_contains 'Hello Maciek', mail.subject
  end

  should 'trigger sms notification alerts with the form' do
    SmsNotifier::Message::DummyTwilioClient.any_instance.expects(:create).with do |hash|
      hash == {
        body: "Your id is #{@user.id}",
        to: '+48123456789',
        from: 'test_501'
      }
    end.once
    put_via_redirect "/api/users/#{@user.id}", form: { first_name: 'Maciek' },
                                               form_configuration_id: form_configuration_with_sms_notification.id
    assert_response :success
  end

  should 'trigger api call notification alerts with the form' do
    stub_request(:post, "https://example.com/user_updates/#{@user.id}")
      .with(body: '{ first_name: Maciek }',
            headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Content-Type' => 'application/json',
                       'Host' => 'example.com',
                       'User-Agent' => 'Ruby' })
      .to_return(status: 200, body: '', headers: {})
    put_via_redirect "/api/users/#{@user.id}", form: { first_name: 'Maciek' },
                                               form_configuration_id: form_configuration_with_api_call_notification.id
    assert_response :success
  end

  protected

  def form_configuration_with_email_notification
    form_configuration do |fc|
      fc.email_notifications.create!(
        name: 'send_hello_email',
        from: 'maciek@example.com',
        to: '{{ form.model.email }}',
        content: 'Your id is {{ form.model.id }}',
        subject: 'Hello {{ form.model.first_name }}'
      )
    end
  end

  def form_configuration_with_sms_notification
    form_configuration do |fc|
      fc.sms_notifications.create!(
        name: 'send_hello_sms',
        to: '{{ form.model.mobile_number }}',
        content: 'Your id is {{ form.model.id }}'
      )
    end
  end

  def form_configuration_with_api_call_notification
    form_configuration do |fc|
      fc.api_call_notifications.create!(
        name: 'send_hello_api_call',
        to: 'https://example.com/user_updates/{{ form.model.id }}',
        content: '{ first_name: {{ form.model.first_name }} } ',
        request_type: 'POST',
        headers: '{"Content-Type": "application/json"}'
      )
    end
  end

  def form_configuration
    @form_configuration ||= FormConfiguration.create!(
      name: 'update_profile_with_notification',
      base_form: 'UserForm',
      configuration: {
        first_name: {
          validation: { presence: {} }
        }
      }
    ).tap { |fc| yield(fc) }
  end
end
