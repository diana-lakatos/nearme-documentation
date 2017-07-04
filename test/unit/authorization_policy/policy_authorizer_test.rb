# frozen_string_literal: true
require 'test_helper_lite'
class AuthorizationPolicy
  class PolicyAuthorizerTest < ActiveSupport::TestCase
    context 'authorized?' do
      should 'should return true if text matches the one expected' do
        assert AuthorizationPolicy::PolicyAuthorizer.authorized?(AuthorizationPolicy::PolicyAuthorizer::AUTHORIZED_TEXT)
      end

      should 'should return true despite white spaces' do
        assert AuthorizationPolicy::PolicyAuthorizer.authorized?(
          " \n \t  #{AuthorizationPolicy::PolicyAuthorizer::AUTHORIZED_TEXT}\t \n  \n"
        )
      end

      should 'should not be case sensitive' do
        assert AuthorizationPolicy::PolicyAuthorizer.authorized?(AuthorizationPolicy::PolicyAuthorizer::AUTHORIZED_TEXT.upcase)
        assert AuthorizationPolicy::PolicyAuthorizer.authorized?(AuthorizationPolicy::PolicyAuthorizer::AUTHORIZED_TEXT.downcase)
      end

      should 'should return false if nothing is returned' do
        refute AuthorizationPolicy::PolicyAuthorizer.authorized?('')
      end

      should 'should return false if string does not match' do
        refute AuthorizationPolicy::PolicyAuthorizer.authorized?('me true not')
      end

      should 'should return false if only white spaces are returned' do
        refute AuthorizationPolicy::PolicyAuthorizer.authorized?("\n   \t \n")
      end
    end
    context 'unauthorized?' do
      should 'be true if unathorized' do
        assert AuthorizationPolicy::PolicyAuthorizer.unauthorized?('me ture not')
      end

      should 'be false if authorized' do
        refute AuthorizationPolicy::PolicyAuthorizer.unauthorized?(AuthorizationPolicy::PolicyAuthorizer::AUTHORIZED_TEXT)
      end
    end
  end
end
