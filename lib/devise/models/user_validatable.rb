# frozen_string_literal: true
module Devise
  module Models
    module UserValidatable
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          validate do
            errors.add(:email, :unique) if User.where.not(id: model.id).where(email: email).exists?
            # update form does not need to have email, but if it has, it can't be blank
            errors.add(:email, :blank) if model.email.blank? && email.blank?
          end
          validates_with PasswordValidator, if: -> (form) { form.model.password.present? && !(form.model.new_record? && form.model.authentications.size.positive?) }
        end
      end
    end
  end
end
