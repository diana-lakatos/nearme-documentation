# frozen_string_literal: true
class ThemeDrop < BaseDrop
  # @return [ThemeDrop]
  attr_reader :theme

  # @!method blog_url
  #   @return [String] URL to this marketplace's blog
  # @!method gplus_url
  #   @return [String] URL to this marketplace's Google Plus page
  # @!method twitter_url
  #   @return [String] URL to this marketplace's twitter page
  # @!method facebook_url
  #   @return [String] URL to this marketplace's Facebook page
  # @!method support_url
  #   @return [String] URL to this marketplace's support page
  # @!method address
  #   @return [String] Address of the entity behind this marketplace
  # @!method phone_number
  #   @return [String] Phone number of the entity behind this marketplace
  # @!method site_name
  #   @return [String] Name of the marketplace
  # @!method pages
  #   @return [Array<PageDrop>] Array of pages created for this marketplace by the marketplace admin
  delegate :blog_url, :gplus_url, :twitter_url, :facebook_url, :support_url,
           :address, :phone_number, :site_name, :pages, to: :theme

  def initialize(theme)
    @theme = theme
  end
end
