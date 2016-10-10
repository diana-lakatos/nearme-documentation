require 'test_helper'

class SecuredDomainTest < ActionDispatch::IntegrationTest
  setup do
    Rails.application.config.stubs(:secure_app).returns(true)
    CreateElbJob.stubs(:perform)
  end

  context 'root request' do
    context 'via unsecured protocol' do
      context 'for unsecured domain' do
        should 'not be redirected to secured domain' do
          domain = FactoryGirl.create(:unsecured_domain, name: 'unsecured.com')
          host! domain.name
          get root_path
          assert_response :success
        end
      end

      context 'for secured domain' do
        should 'be redirected to secured domain' do
          domain = FactoryGirl.create(:secured_domain, name: 'secured.com')
          host! domain.name
          get root_url(host: domain.name, protocol: 'http')
          assert_redirected_to root_url(host: domain.name, protocol: 'https')
        end
      end
    end
  end

  context 'login request' do
    context 'via secured domain' do
      should 'stay on same domain' do
        domain = FactoryGirl.create(:secured_domain, name: 'secured.com')
        https!
        host! domain.name
        get dashboard_url
        assert_redirected_to new_user_session_url(host: domain.name, protocol: 'https', return_to: dashboard_url)
      end
    end

    context 'via unsecured protocol' do
      should 'be redirected to secured login' do
        domain = FactoryGirl.create(:unsecured_domain, name: 'unsecured.com')
        secured_domain = FactoryGirl.create(:secured_domain, name: 'secured.com')
        host! domain.name
        get dashboard_url
        assert_redirected_to new_user_session_url(host: secured_domain.name, protocol: 'https', return_to: dashboard_url)
      end

      should 'be redirected back with valid token' do
        domain = FactoryGirl.create(:unsecured_domain, name: 'unsecured.com')
        user = FactoryGirl.create(:user)
        host! domain.name
        User::TemporaryTokenVerifier.any_instance.stubs(generate: 'my_little_token')

        user_hash = { user: { email: user.email, password: user.password } }
        post user_session_url(user_hash.merge(host: 'example.com', protocol: 'https', return_to: dashboard_url(host: domain.name, protocol: 'http')))
        assert_response :redirect
        assert_redirected_to dashboard_url(host: domain.name, protocol: 'http', token: 'my_little_token')
      end
    end
  end

  context 'logout request' do
    context 'for multiple logins' do
      should 'destroy all logins' do
        user = FactoryGirl.create(:user)
        unsecured = FactoryGirl.create(:unsecured_domain, name: 'unsecured.com')
        secured = FactoryGirl.create(:secured_domain, name: 'secured.com')

        login_hash = {
          'user' => {
            'email' => user.email,
            'password' => user.password
          }
        }

        post user_session_url(host: secured.name, protocol: 'https'), login_hash
        follow_redirect!
        assert_response :success
        assert_equal user, controller.current_user
        post user_session_url(host: unsecured.name), login_hash
        follow_redirect!
        assert_response :success
        assert_equal user, controller.current_user

        delete destroy_user_session_url(host: unsecured.name)
        follow_redirect!
        assert_response :success

        get root_url(host: unsecured.name)
        assert_nil controller.current_user
        get root_url(host: secured.name)
        assert_nil controller.current_user
      end
    end
  end
end
