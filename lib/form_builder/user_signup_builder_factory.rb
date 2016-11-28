# frozen_string_literal: true
class FormBuilder
  class UserSignupBuilderFactory
    DEFAULT = 'default'
    ENQUIRER = 'enquirer'
    LISTER = 'lister'
    class << self
      def builder(role)
        case role
        when DEFAULT, '', nil
          FormConfiguration.find_by(base_form: 'UserSignup::DefaultUserSignup')
        when LISTER, 'seller'
          FormConfiguration.find_by(base_form: 'UserSignup::ListerUserSignup')
        when ENQUIRER, 'buyer'
          FormConfiguration.find_by(base_form: 'UserSignup::EnquirerUserSignup')
        else
          raise ArgumentError
        end
      end
    end
  end
end
