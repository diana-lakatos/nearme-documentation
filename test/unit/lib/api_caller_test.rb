require 'test_helper'
class ApiCallerTest < ActiveSupport::TestCase

  module DummyWorkflow
    class DummyStep < WorkflowStep::BaseStep

      def initialize(dummy_arg)
        @dummy_arg = dummy_arg
      end

      def data
        { dummy_arg: @dummy_arg }
      end

      def should_be_processed?
        true
      end

    end
  end

  class DummyArgDrop < BaseDrop
    attr_reader :dummy_arg
    delegate :name, :id, to: :dummy_arg
    def initialize(dummy_arg)
      @dummy_arg = dummy_arg
    end
  end

  setup do
    @arg = stub(to_liquid: DummyArgDrop.new(stub(name: 'dummy name!', id: 5)))
    @step = DummyWorkflow::DummyStep.new(@arg)
    stub_request(:put, "http://example.com/?special_arg=5").with(:body => "{\"name\":\"dummy name!\"}",
       :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Custom-Header'=>'dummy name!', 'Host'=>'example.com', 'User-Agent'=>'Ruby'})
    WorkflowAlert.stubs(:find).returns(stub(default_hash))
  end

  should 'should properly parse liquid' do
    ApiCaller.call(@step, 1)
  end

  should 'properly store error' do
    Net::HTTP::Put.expects(:new).raises(StandardError.new('Epic fail'))
    Rails.application.config.marketplace_error_logger.class.any_instance.stubs(:log_issue).with do |error_type, msg|
      error_type == MarketplaceErrorLogger::BaseLogger::API_CALL_ERROR && msg.include?("DummyWorkflow::DummyStep") && msg.include?("http://example.com/?special_arg=5") && msg.include?("Epic fail")
    end
    ApiCaller.call(@step, 1)
  end

  context 'logger' do
    setup do
      WorkflowAlertLogger.setup { |config| config.logger_type = :db }
    end

    should 'create correct log entry for sms' do
      WorkflowAlertLogger.any_instance.expects(:db_log!)
      ApiCaller.call(@step, 1)
    end

    teardown do
      WorkflowAlertLogger.setup { |config| config.logger_type = :none }
    end

  end

  protected

  def default_hash
    { endpoint: "http://example.com/?special_arg={{ dummy_arg.id }}",
      request_type: 'PUT',
      use_ssl: false,
      payload_data: { name: "{{ dummy_arg.name }}" }.to_json,
      headers:  { 'Custom-Header' => "{{ dummy_arg.name }}" }.to_json
    }
  end

end
