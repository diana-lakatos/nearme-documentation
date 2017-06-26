# frozen_string_literal: true
require 'test_helper_lite'
require 'mocha/setup'
require 'mocha/mini_test'
class AuthorizationPolicy
  class EvaluatedPolicyTest < ActiveSupport::TestCase
    context 'to_s' do
      context 'user condition' do
        should 'properly evaluate policy if condition succeeds' do
          assert_equal 'true', EvaluatedPolicy.new(
            user: user_maciek, policy: '{% if current_user.first_name == \'Maciek\'%}true{% else%}false{% endif %}'
          ).to_s
        end

        should 'properly evaluate policy if condition fails' do
          assert_equal 'false', EvaluatedPolicy.new(
            user: user_john, policy: '{% if current_user.first_name == \'Maciek\'%}true{% else%}false{% endif %}'
          ).to_s
        end
      end
      context 'object condition' do
        should 'properly evaluate policy if condition succeeds' do
          assert_equal 'true', EvaluatedPolicy.new(
            user: mock, object: user_maciek, policy: '{% if object.first_name == \'Maciek\'%}true{% else%}false{% endif %}'
          ).to_s
        end
        should 'properly evaluate policy if condition fails' do
          assert_equal 'false', EvaluatedPolicy.new(
            user: mock, object: user_john, policy: '{% if object.first_name == \'Maciek\'%}true{% else%}false{% endif %}'
          ).to_s
        end
      end
    end

    protected

    def user_maciek
      mock(to_liquid: {
             'first_name' => 'Maciek'
           })
    end

    def user_john
      mock(to_liquid: {
             'first_name' => 'John'
           })
    end
  end
end
