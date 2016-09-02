require 'net/http'
require 'json'

namespace :animalist do
  desc 'Parses data from their api and creates what needs to be created'
  task setup: :environment do
    Instance.find(201).set_context!
    AnimalistRakeHelper.go!
  end
end

class AnimalistRakeHelper

  class << self

    def go!
      InstanceView.where(instance_id: PlatformContext.current.instance.id, path: 'tag_page_content', handler: 'liquid', format: 'html', partial: true, view_type: 'view').destroy_all
      InstanceView.where(instance_id: PlatformContext.current.instance.id, path: 'tag_page_content', handler: 'liquid', format: 'html', partial: true, view_type: 'view').create! do |iv|
        iv.body = tag_page_content
        iv.locales << Locale.all
      end
      InstanceView.where(instance_id: PlatformContext.current.instance.id, path: 'show_page_content', handler: 'liquid', format: 'html', partial: true, view_type: 'view').destroy_all
      InstanceView.where(instance_id: PlatformContext.current.instance.id, path: 'show_page_content', handler: 'liquid', format: 'html', partial: true, view_type: 'view').create! do |iv|
        iv.body = page_content
        iv.locales << Locale.all
      end
      parse_episodes!
    end

    def parse_episodes!(page_number = 1)

      url = "http://api.ddn.io/v1/episodes/#{page_number}?domain=animalist.com"
      uri = URI(url)
      response = JSON.parse(Net::HTTP.get(uri))

      puts "Parsing episodes for page: #{page_number}"

      response["data"].each do |data|

        page_slug = data["path"].split('/')[1]
        page = Page.where(slug: page_slug, theme_id: PlatformContext.current.theme.id).first_or_initialize(path: page_slug.humanize)
        page.content = "{% include 'show_page_content.html' %}"
        page.css_content = ''
        page.save!

        puts "\tCreating (if_needed) page with slug: #{page_slug}"

        data_source = page.data_sources.where(type: 'DataSource::CustomSource', label: page_slug).first_or_create! do |ds|
          puts "\t\tneeded :)"
          ds.settings = { endpoint: "http://api.ddn.io/v1#{data["path"]}?domain=animalist.com" }
        end

        puts "\t\tAssociating data source with label: #{data["path"]}"
        data_source_content = data_source.data_source_contents.where(external_id: data["id"]).first_or_create! do |dsc|
          puts "\t\t\tNew data source content #{data["id"]}"
          dsc.external_id = data["id"]
          dsc.externally_created_at = data["publishTime"].to_time
          uri = URI("http://api.ddn.io/v1#{data["path"]}?domain=animalist.com")
          dsc.json_content =  JSON.parse(Net::HTTP.get(uri))
        end

        page.page_data_source_content.where(data_source_content: data_source_content, slug: page_slug).first_or_create!
        page.page_data_source_content.where(data_source_content: data_source_content, slug: data["path"][1..-1]).first_or_create!
        data_source_content.json_content['data']['tags']['data'].each do |tag|
          tag_page = Page.where(slug: tag['slug'], theme_id: PlatformContext.current.theme.id).first_or_initialize(path: tag['name'])
          tag_page.content = "{% include 'tag_page_content.html' %}"
          tag_page.css_content = ''
          tag_page.save!
          tag_page.page_data_source_content.where(data_source_content: data_source_content, slug: tag['slug']).first_or_create!
        end
      end
      if response["data"].any?
        parse_episodes!(page_number + 1)
      end
    end

    def page_content
      %Q{

{% assign cache_key = "page" | append: params.page | append: "slug" | append: params.slug | append: "slug2" | append: params.slug2 | append: data_source_last_update  %}
{% cache_for @cache_key %}
  {% if params.slug2 == blank %}
    <div class="main-cols-central">
      <ul>
        {% for dsc in data_source_contents %}
          {% assign data_source_content = dsc.json_content.data %}
          <li class="feed-item">
            <article class="feed-article">
              <a href="{{data_source_content.show.data.slug}}/{{ data_source_content.slug }}" class="feed-article-anchor"></a>
              {% assign url = data_source_content.thumbnails.medium.data.url | replace: "\/", "/"%}
              <div class="picture feed-article-thumbnail" style="background-image: url('{{ url }}')"></div>
              <div class="feed-article-text">
                <h2 class="feed-article-title">{{ data_source_content.name }}</h2>
                <p class="feed-article-subtitle">{{ data_source_content.summary }}</p>
                <p class="feed-article-postscript"><a href="/{{ data_source_content.show.data.slug }}"><span class="show-name">{{ data_source_content.show.data.name }}</span></a><span class="timestamp"><span> – </span><time datetime="{{ data_source_content.publishTime }}">{{ data_source_content.publishTime }}</time></span></p>
              </div>
            </article>
          </li>
        {% endfor %}
      </ul>

      {% will_paginate collection: data_source_contents, inner_window: 1, outer_window: 0, class: '' %}

    </div>

  {% else %}
    {% assign data_source_content = data_source_contents.first.json_content.data %}
    <div class="main-cols-central">
      <article clas="episode-article">
        <p class="episode-meta">
        <a href="/{{ data_source_content.show.data.slug }}"><span class="show-name">{{ data_source_content.show.data.name }}</span></a>
        <span class="timestamp"> <span> – </span> <time datetime="{{ data_source_content.publishTime }}">{{ data_source_content.publishTime }}</time> </span>
        </p>
        <h1 class="episode-title">{{ data_source_content.name }}
        </h1>
        <section class="episode-copy" id="episode-copy">
          <h4 class="episode-summary">{{ data_source_content.summary }}</h4>
          <div class="episode-description">{{ data_source_content.description }}</div>
        </section>
        <ul class="episode-tags">
          {% for tag_data in data_source_content.tags.data %}
            <li>
              <a href="/{{ tag_data.slug }}"><p>{{ tag_data.name }}</p></a>
            </li>
          {% endfor %}
        </ul>
      </article>
    </div>

  {% endif %}
{% endcache_for %}
      }

    end

    def page_css
      %Q{
      body {
background-color: #f4f4f4;
    color: #222;
    font-family: "Open Sans",Open,sans-serif;
    font-size: 1rem;
    -webkit-font-smoothing: subpixel-antialiased;
    font-weight: 400;
    letter-spacing: .0125rem;
    line-height: 1.5;
    min-width: 320px;
    text-rendering: optimizeLegibility;
}

.main-cols-wrap {
    font-size: 0;
    margin: 40px auto;
    max-width: 960px;
    position: relative;
}

.main-cols-central {
    background-color: #fff;
    box-shadow: 0 0 10px rgba(34,34,34,.1);
    margin: 0 auto;
    max-width: 640px;
    padding: 20px;
    display: inline-block;
    font-size: medium;
    text-align: left;
    vertical-align: top;
}

.feed-item {
border-bottom: 1px solid #e4e4e4;
    font-size: 0;
    padding: 20px 0;
    position: relative;
    text-align: left;
}

.feed-article-anchor {
bottom: 0;
    left: 0;
    position: absolute;
    right: 0;
    top: 0;
    z-index: 1;
}

.feed-article-thumbnail {
    padding-bottom: 168.75px;
    width: 300px;

background-color: #d7d7d7;

    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
    display: inline-block;
    height: 0;
    margin-right: 20px;
    position: relative;
    vertical-align: top;

}

.feed-article-text {
    color: #222;
    display: inline-block;
    font-size: 1rem;
    vertical-align: top
}

.feed-article-title {
    color: #222;
    line-height: 1.25;
    margin-bottom: 10px;
    -webkit-transition: color .25s;
    transition: color .25s;
}

.feed-article-postscript {
    color: #979797;
    font-size: .75rem;
    font-style: italic;
    margin: 10px 0 0;
}

.show-name {
    font-style: normal;
    position: relative;
    -webkit-transition: color .25s;
    transition: color .25s;
    z-index: 1;
    color: #ffb624;
}

.episode-title {
    line-height: 1.333;
    margin: 10px 0 20px;
}

.episode-copy {
    margin-top: 25px;
    overflow-wrap: break-word;
}

.episode-tags {
    font-size: 0;
    margin-left: -5px;
}

ol, ul {
    list-style: none;
}

.episode-tags li {
    background-color: #fff;
    border: 1px solid #ffb624;
    color: #ffb624;
    display: inline-block;
    font-size: .825rem;
    line-height: 1;
    margin: 5px;
    -webkit-transition: all .25s;
    transition: all .25s;
    text-transform: uppercase;
}

.episode-tags li p {
    padding: 5px 5px 2.5px;
}


      }

    end

    def tag_page_content
      %Q{

{% assign cache_key = "page" | append: params.page | append: "slug" | append: params.slug | append: data_source_last_update  %}
{% cache_for cache_key %}
  <h1>{{ params.slug | humanize }}</h1>
  <div class="main-cols-central">
    <ul>
      {% for dsc in data_source_contents %}
        {% assign data_source_content = dsc.json_content.data %}
        <li class="feed-item">
          <article class="feed-article">
            <a href="{{data_source_content.show.data.slug}}/{{ data_source_content.slug }}" class="feed-article-anchor"></a>
            {% assign url = data_source_content.thumbnails.medium.data.url | replace: "\/", "/"%}
            <div class="picture feed-article-thumbnail" style="background-image: url('{{ url }}')"></div>
            <div class="feed-article-text">
              <h2 class="feed-article-title">{{ data_source_content.name }}</h2>
              <p class="feed-article-subtitle">{{ data_source_content.summary }}</p>
              <p class="feed-article-postscript"><a href="/{{ data_source_content.show.data.slug }}"><span class="show-name">{{ data_source_content.show.data.name }}</span></a><span class="timestamp"><span> – </span><time datetime="{{ data_source_content.publishTime }}">{{ data_source_content.publishTime }}</time></span></p>
            </div>
          </article>
        </li>
      {% endfor %}
    </ul>

    {% will_paginate collection: data_source_contents, inner_window: 1, outer_window: 0, class: '' %}
  </div>
{% endcache_for %}

      }

    end
  end
end

