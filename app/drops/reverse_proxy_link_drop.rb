# frozen_string_literal: true
class ReverseProxyLinkDrop < BaseDrop
  # @return [ReverseProxyLinkDrop]
  attr_reader :source

  # @!method id
  #   @return [Integer] numeric identifier for the object
  # @!method name
  #   @return [String] Name for the reverse proxy link 
  # @!method destination_path
  #   @return [String] Destination path for the reverse proxy link
  # @!method use_on_path
  #   @return [String] Path to be used on
  delegate :id, :name, :destination_path, :use_on_path, to: :source

  def initialize(source)
    @source = source
  end
end
