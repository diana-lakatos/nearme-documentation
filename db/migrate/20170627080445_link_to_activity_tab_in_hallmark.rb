# frozen_string_literal: true
class LinkToActivityTabInHallmark < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        content = <<EOC
{% assign attachment = comment.activity_feed_images.first %}
{% if attachment != blank %}
  {% assign truncateValue = 90 %}
{% else %}
  {% assign truncateValue = 110 %}
{% endif %}

{% assign is_listing_url = comment.commentable.url | split: '/listings/' %}

{% if is_listing_url.size == 2 %}
  {% assign commentable_url = comment.commentable.url | append: '#activity-tab' %}
{% else %}
  {% assign commentable_url = comment.commentable.url %}
{% endif %}

<article{% if attachment != blank %} class="has-attachment"{% endif %}>
  <figure class="avatar"><a href="{{ comment.creator.profile_path }}"><img src="{{ comment.creator.avatar.url }}"></a></figure>
  <h3 class="hx"><a href="{{ comment.creator.profile_path }}">{{ comment.creator.name }}</a> posted on <a href="{{ commentable_url }}">{{ comment.commentable.name }}</a></h3>
  <p>{{ comment.body  | truncate: truncateValue }}</p>
  {% if attachment != blank %}
    <a href="{{ attachment.full }}"
      class="attachment"
      data-original-width="{{ attachment.image_original_width }}"
      data-original-height="{{ attachment.image_original_height }}">
      <img src="{{ attachment.thumb }}" alt="Post attachment miniature">
    </a>
  {% endif %}
</article>
EOC

        iv = i.instance_views.where(path: 'home/comment_entry').first
        iv.body = content
        iv.save!
      end
    end
  end

  def down
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        i.set_context!

        content = <<EOC
{% assign attachment = comment.activity_feed_images.first %}
{% if attachment != blank %}
  {% assign truncateValue = 90 %}
{% else %}
  {% assign truncateValue = 110 %}
{% endif %}

<article{% if attachment != blank %} class="has-attachment"{% endif %}>
  <figure class="avatar"><a href="{{ comment.creator.profile_path }}"><img src="{{ comment.creator.avatar.url }}"></a></figure>
  <h3 class="hx"><a href="{{ comment.creator.profile_path }}">{{ comment.creator.name }}</a> posted on <a href="{{ comment.commentable.url }}">{{ comment.commentable.name }}</a></h3>
  <p>{{ comment.body  | truncate: truncateValue }}</p>
  {% if attachment != blank %}
    <a href="{{ attachment.full }}"
      class="attachment"
      data-original-width="{{ attachment.image_original_width }}"
      data-original-height="{{ attachment.image_original_height }}">
      <img src="{{ attachment.thumb }}" alt="Post attachment miniature">
    </a>
  {% endif %}
</article>
EOC

        iv = i.instance_views.where(path: 'home/comment_entry').first
        iv.body = content
        iv.save!
      end
    end
  end
end
