# frozen_string_literal: true
require 'active_support/concern'

module Encryptable
  extend ActiveSupport::Concern

  included do
    # TODO: Update defaults https://github.com/attr-encrypted/attr_encrypted#deprecations
    attr_encrypted_options.merge!(key: :encryption_key,
                                  encryptor: AttrEncryptedEncryptor)
  end

  def encryption_key
    DesksnearMe::Application.config.secret_token
  end
end
