require 'test_helper'

class Attachable::PaymentDocumentInfoTest < ActiveSupport::TestCase
  should belong_to(:instance)
  should belong_to(:payment_document)
  should belong_to(:document_requirement)
end
