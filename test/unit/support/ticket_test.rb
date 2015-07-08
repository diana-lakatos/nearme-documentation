require 'test_helper'

class SampleMailer < ActionMailer::Base
  def simple_message
    mail(to: 'test@test.com', subject: 'The Subject') do |format|
      format.text { render text: 'Content' }
    end
  end

  def multipart_message
    mail(to: 'test@test.com', subject: 'The Subject') do |format|
      format.html { render text: '<p>Content</p>' }
      format.text { render text: 'Content' }
    end
  end
end

class Support::TicketTest < ActiveSupport::TestCase
  context '::body_for_message' do
    should 'force encoding for simple message' do
      message = SampleMailer.simple_message
      assert_equal 'Content', Support::Ticket.body_for_message(message)
    end

    should 'force encoding for multipart message' do
      message = SampleMailer.multipart_message
      assert_equal 'Content', Support::Ticket.body_for_message(message)
    end

    should 'not force encoding if it is not mentioned in the content type' do
      message = SampleMailer.simple_message
      message.stubs(:content_type).returns('text/plain;')
      assert_equal 'Content', Support::Ticket.body_for_message(message)
    end
  end
end
