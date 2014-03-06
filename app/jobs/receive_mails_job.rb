class ReceiveMailsJob < Job
  def perform
    receive = Support::ReceiveMails.new
    receive.start!
  end
end
