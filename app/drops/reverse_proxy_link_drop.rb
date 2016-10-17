class ReverseProxyLinkDrop < BaseDrop

  # @return [ReverseProxyLink]
  attr_reader :source

  # @!method id
  #   @return [Integer] numeric identifier for the object
  # @!method name
  #   Name for the reverse proxy link
  #   @return (see ReverseProxyLink#name)
  # @!method destination_path
  #   Destination path for the reverse proxy link
  #   @return (see ReverseProxyLink#destination_path)
  # @!method use_on_path
  #   Path to be used on
  #   @return (see ReverseProxyLink#use_on_path)
  delegate :id, :name, :destination_path, :use_on_path, to: :source

  def initialize(source)
    @source = source
  end

end
