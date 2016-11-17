# frozen_string_literal: true
class ThemeDrop < BaseDrop
  # @return [ThemeDrop]
  attr_reader :theme

  # @!method blog_url
  #   URL to this marketplace's blog
  #   @return (see Theme#blog_url)
  # @!method gplus_url
  #   URL to this marketplace's Google Plus page
  #   @return (see Theme#gplus_url)
  # @!method twitter_url
  #   URL to this marketplace's twitter page
  #   @return (see Theme#twitter_url)
  # @!method facebook_url
  #   URL to this marketplace's Facebook page
  #   @return (see Theme#facebook_url)
  # @!method support_url
  #   URL to this marketplace's support page
  #   @return (see Theme#support_url)
  # @!method address
  #   Address of the entity behind this marketplace
  #   @return (see Theme#address)
  # @!method phone_number
  #   Phone number of the entity behind this marketplace
  #   @return (see Theme#phone_number)
  # @!method site_name
  #   Name of the marketplace
  #   @return (see Theme#site_name)
  # @!method pages
  #   @return [Array<PageDrop>] Array of pages created for this marketplace by the marketplace admin
  delegate :blog_url, :gplus_url, :twitter_url, :facebook_url, :support_url,
           :address, :phone_number, :site_name, :pages, to: :theme

  def initialize(theme)
    @theme = theme
  end
end
