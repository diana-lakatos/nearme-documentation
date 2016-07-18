class ReverseProxyLinkDrop < BaseDrop

  attr_reader :source

  def initialize(source)
    @source = source
  end

  # destination_path
  #   returns destination path for a link
  # name
  #   returns name
  delegate :id, :name, :destination_path, :use_on_path, to: :source

end
