module InfiniteScrollHelper
  def options_for_infinite_scroll(type, options = {})
    send("#{type}_infinite_scroll_options", options)
  end

  def activity_feed_infinite_scroll_options(options)
    {
      id: options[:object].id,
      type: options[:object].class.name,
      page: 1
    }.to_json
  end

  def followers_and_following_infinite_scroll_options(options)
    {
      id: options[:object].id,
      type: options[:object].class.name,
      method_name: options[:method_name].to_s,
      container: options[:container],
      attribute: options[:attribute],
      page: 1
    }.to_json
  end
end
