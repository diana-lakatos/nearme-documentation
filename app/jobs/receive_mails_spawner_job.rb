class ReceiveMailsSpawnerJob < Job
  def perform
    Instance.with_support_imap.each do |instance|
      PlatformContext.current = PlatformContext.new(instance)
      ReceiveMailsJob.perform
    end
  end
end
