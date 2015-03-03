require 'test_helper'

class Attachable::PaymentDocumentTest < ActiveSupport::TestCase
  should have_one(:payment_document_info)
end
