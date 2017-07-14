# frozen_string_literal: true
class ApiCaller
  extend Job::SyntaxEnhancer

  def self.call(step, workflow_id, metadata: {})
    @step = step
    return unless @step.should_be_processed?
    @workflow_alert = WorkflowAlert.find(workflow_id)
    return unless @workflow_alert.should_be_triggered?(step)

    result = nil
    parsed_endpoint = parser.parse(@workflow_alert.endpoint, @step.data)
    parsed_headers = parser.parse(@workflow_alert.headers, @step.data)
    parsed_body = parser.parse(@workflow_alert.payload_data, @step.data)
    begin
      uri = URI.parse(parsed_endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = @workflow_alert.use_ssl
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @workflow_alert.use_ssl
      http.read_timeout = 1
      request = "Net::HTTP::#{@workflow_alert.request_type.capitalize}".constantize.new(uri)
      JSON.parse(parsed_headers).each do |key, value|
        request.add_field(key, value)
      end
      request.body = parsed_body
      http.request(request)

      result = true
    rescue => e
      MarketplaceLogger.error(MarketplaceErrorLogger::BaseLogger::API_CALL_ERROR, "Failed to trigger api call for #{@step.class.name}, endpoint: #{parsed_endpoint}, body: #{parsed_body.inspect}, headers: #{parsed_headers}. Error: #{e}")
    end
    WorkflowAlertLogger.new(@workflow_alert).log!
    result
  end

  protected

  def self.parser
    @parser ||= Liquify::LiquidTemplateParser.new
  end
end
