class UserBaseDrop < BaseDrop
  include ActionView::Helpers::AssetUrlHelper
  include ClickToCallButtonHelper

  # @return [String] path to a user's public profile
  # @todo -- depracate url for filter
  def user_profile_url
    routes.profile_path(@source.slug)
  end

  # @return [String] path to a user's public profile
  # @todo -- depracate url for filter
  def profile_path
    routes.profile_path(@source.slug)
  end

  # @return [String] path to the user's blog
  # @todo -- depracate url for filter
  def user_blog_posts_list_path
    routes.user_blog_posts_list_path(@source.slug)
  end

  # @return [String] path to the section in the application for sending a message to this user using the
  #   marketplace's internal messaging system
  # @todo -- depracate url for filter
  def user_message_path
    routes.new_user_user_message_path(user_id: @source.slug)
  end

  # @return [String, nil] click to call button for this user if enabled for this
  #   marketplace
  # @todo -- depracate in favor of DIY - especially looking at logic in this helper, this will be very hard to document at all
  def click_to_call_button
    build_click_to_call_button_for_user(@source)
  end
end
