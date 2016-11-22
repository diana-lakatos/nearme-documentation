# frozen_string_literal: true
require 'net/http'
require 'json'

namespace :longtail do
  desc 'Parses data from their api and creates what needs to be created'

  task desksnearme: :environment do
    Instance.find(1).set_context!
    page = Page.where(slug: 'workspace', theme_id: PlatformContext.current.theme.id).first_or_create!(path: 'Workplace') do |p|
      p.redirect_url = nil
      p.content = LongtailRakeHelper.generic_page_content
      p.css_content = ''
    end
    LongtailRakeHelper.parse_keywords!(page, '341413f7e17c0a48eb605e08bdbce7d2')
  end

  task spacer: :environment do
    Instance.find(130).set_context!
    page = Page.where(slug: 'storage', theme_id: PlatformContext.current.theme.id).first_or_create!(path: 'Storage')
    LongtailRakeHelper.parse_keywords!(page, '07eacc2262eec5d0216561b4f6c8725c')
  end
end

class LongtailRakeHelper
  class << self
    def parse_keywords!(page, token, url = 'http://api.longtailux.com/keywords/seo?page_limit=10000')
      url = URI.parse(url)
      http = Net::HTTP.new(url.host, url.port)
      req = Net::HTTP::Get.new(url)
      req.add_field('Authorization', "Bearer #{token}")
      response = http.request(req)
      keywords = JSON.parse(response.body)

      @main_data_source = page.data_sources.where(type: 'DataSource::CustomSource', label: page.slug).first_or_create!

      keywords['data'].each do |keyword|
        ensure_100_requests_per_minute!

        host = "http://api.longtailux.com/search/seo/#{keyword['attributes']['slug']}"
        url = URI.parse(host)
        http = Net::HTTP.new(url.host, url.port)
        req = Net::HTTP::Get.new(url)
        req.add_field('Authorization', "Bearer #{token}")
        response = http.request(req)
        while response.body == 'Too Many Attempts.'
          puts 'Too many attempts, retrying after 5secs...'
          sleep(5)
          response = http.request(req)
        end
        unless response.body =~ /^{"data"/
          puts "\tSkipping keyword: #{host}"
          puts response.body
          next
        end

        data_source_content = @main_data_source.data_source_contents.where(external_id: keyword['id']).first_or_create!
        puts "\tNew data source content for #{keyword['attributes']['slug']}"
        data_source_content.external_id = keyword['id']
        data_source_content.externally_created_at = nil
        parsed_body = JSON.parse(response.body)
        parsed_body['included'].each_with_index do |item, index|
          transactable = Transactable.with_deleted.find_by(id: item['attributes']['guid'])
          if transactable.nil?
            puts "\t\tSkipping additional attributes - no transactable #{item['attributes']['guid']}"
            next
          end
          parsed_body['included'][index]['attributes']['price'] = {}
          transactable.action_type.pricings.each do |pricing|
            parsed_body['included'][index]['attributes']['price'][pricing.unit] = pricing.price.to_s
          end
          parsed_body['included'][index]['attributes']['photos'] = transactable.photos_metadata.try(:map) { |p| p['space_listing'] }
          parsed_body['included'][index]['attributes']['address'] = transactable.formatted_address
          parsed_body['included'][index]['attributes']['latitude'] = transactable.latitude
          parsed_body['included'][index]['attributes']['longitude'] = transactable.longitude
          parsed_body['included'][index]['attributes']['currency'] = transactable.currency
          transactable.properties.to_h.each do |k, v|
            parsed_body['included'][index]['attributes'][k] = v
          end
          parsed_body['included'][index]['attributes']['categories'] = transactable.to_liquid.categories
        end
        data_source_content.json_content = parsed_body
        data_source_content.save!
        page.page_data_source_contents.where(data_source_content: data_source_content, slug: keyword['attributes']['url'][1..-1]).first_or_create!
      end
      parse_keywords!(page, token, keywords['links']['next']) if keywords['links']['next'].present?
    end

    def ensure_100_requests_per_minute!
      @first_request ||= Time.zone.now.strftime('%M').to_i
      @number_of_requests ||= 0

      if @first_request == Time.zone.now.strftime('%M').to_i
        @number_of_requests += 1
        if @number_of_requests == 100
          puts 'have to sleep, reached 100 requests in the same minute ('
          loop do
            sleep(1)
          end while @first_request == Time.zone.now.strftime('%M').to_i
          @first_request = Time.zone.now.strftime('%M').to_i
          @number_of_requests = 1
        end
      else
        @first_request = Time.zone.now.strftime('%M').to_i
        @number_of_requests = 1
      end
    end

    def generic_page_content
      %(
{% content_for 'meta' %}
  <link rel='stylesheet' media='screen' href='https://rawgit.com/mdyd-dev/marketplaces/master/longtail/dist/app.css'>
  <meta name='keywords' content="{{ @data_source_contents.first.json_content.data.first.attributes.name }}">
{% endcontent_for %}

{% content_for 'body_bottom' %}
  <script src='https://rawgit.com/mdyd-dev/marketplaces/master/longtail/dist/app.js'></script>
{% endcontent_for %}

{% for included_item in data_source_contents.first.json_content.included %}
  {% if included_item.attributes.snippet != blank %}
    {% assign first_snippet = included_item.attributes.snippet %}
    {% break %}
  {% endif %}
{% endfor %}

{% assign description_content = first_snippet | replace_first: '... ', '' | prepend: '... ' | prepend: @data_source_contents.first.json_content.data.first.attributes.name %}
{% content_for 'meta_description' %}
  {{ description_content | truncate: 165  }}
{% endcontent_for %}

{% assign title_text = @data_source_contents.first.json_content.data.first.attributes.name | append: ' - ' | append: @data_source_contents.first.json_content.data.first.relationships.items.data.size | append: platform_context.name  %}
{% title title_text %}

{% assign cache_key = data_source_last_update | append: current_path %}

{% cache_for cache_key, page %}
  {% assign dsc = @data_source_contents.first.json_content %}
  {% if params.slug2 == blank or dsc == blank %}
    <h1>404 does not exist.</h1>
  {% else %}
    <ul class="breadcrumbs list-unstyled">
      <li><a href="/"><i class="fa fa-home" aria-hidden="true"></i></a></li>
      <li><a href="{{ dsc.data.first.attributes.category_url }}">{{ dsc.data.first.attributes.category }}</a></li>
      <li class="active"><a href="{{ dsc.data.first.attributes.url }}">{{ dsc.data.first.attributes.name | titleize }}</a></li>
    </ul>

    {% assign dsc = @data_source_contents.first.json_content %}

    <div>
      <h4>Related listings:</h4>
      <ul>
        {% for similar_storage in dsc.data.first.relationships.similar_searches.data %}
          {% for included_link in dsc.included %}
            {% if included_link.id == similar_storage.id %}
              <li><a href="{{ included_link.attributes.url }}
              ">{{ included_link.attributes.highlighted }}</a></li>
              {% break %}
            {% endif %}
          {% endfor %}
        {% endfor %}
      </ul>
    </div>

    <section class="listings">
      {% for item in dsc.data.first.relationships.items.data %}
        {% for listing in dsc.included %}
          {% if listing.id == item.id %}
            {% assign photos_count = listing.attributes.photos | size %}
            <article class="listing {% if photos_count == 0 %}listing-photos__empty{% endif %}">
              <div class="listing-photos">
                <ul class="listing-photos__carousel" data-carousel>
                  {% if photos_count == 1 %}
                    <li class="active">
                      <a href="{{ listing.attributes.url }}"><img src="{{ listing.attributes.photos[0] }}" alt="{{ listing.attributes.name }}"></a>
                    </li>
                  {% elsif photos_count > 1 %}
                    <li class="listing-photos__carousel--prev"><a href="#" data-carousel-control="prev"><i class="fa fa-chevron-left"></i></a></li>
                    {% for photo in listing.attributes.photos %}
                      <li class="{% if forloop.index == 1 %}active{% endif %}" data-carousel-item>
                        <a href="{{ listing.attributes.url }}"><img src="{{ photo }}" alt="{{ listing.attributes.name }}"></a>
                      </li>
                    {% endfor %}
                    <li class="listing-photos__carousel--next"><a href="#" data-carousel-control="next"><i class="fa fa-chevron-right"></i></a></li>
                  {% else %}
                    <li class="active">
                      <a href="{{ listing.attributes.url }}">
                        <img src="https://d2rw3as29v290b.cloudfront.net/instances/1/uploads/ckeditor/attachment_file/data/3233/placeholder.svg" alt="Photos unavailable or still processing" />
                      </a>
                    </li>
                  {% endif %}
                </ul>
              </div>

              <div class="listing-data">
                <h3><a href="{{ listing.attributes.url }}">
                  {{ listing.attributes.name }}
                </a></h3>

                <h4><p class="listing-data__subheader">
                  {{ listing.attributes.address }}
                </p></h4>

                <p class="listing-data__details">
                  {{ listing.attributes.snippet }}
                </p>
              </div>

              {% unless listing.attributes.categories == blank %}
                <div class="listing-features">
                  {% for category in listing.attributes.categories  %}
                    <p>{{ category.name }}</p>
                    <ul>
                      {% for child in category.children %}
                        <li>{{ child }}</li>
                      {% endfor %}
                    </ul>
                  {% endfor %}
                </div>
              {% endunless %}

              {% unless listing.attributes.price == blank %}
                <div class="listing-pricing">
                  <ul class="list-unstyled">
                    {% for price in listing.attributes.price %}
                      {% assign price_key = "reservations." | append: price[0] | append: '.one' %}
                      <li>{{ price[1] | pricify: listing.attributes.currency }} / {{price_key | t }}</li>
                    {% endfor %}
                  </ul>
                </div>
              {% endunless %}

              <div class="listing-actions">
                <ul class="list-unstyled">
                  <li class="favorite-button-container" data-add-favorite-button="true" data-path="/wish_list/{{ listing.attributes.guid }}/Transactable" data-wishlistable-type="Transactable" data-link-to-classes="button button-default favorite-button" data-path-bulk="/wish_lists/bulk_show" data-object-id="{{ listing.attributes.guid }}" id="favorite-button-Transactable-{{ listing.attributes.guid }}" title="Add to favorites"></li>
                  <li>
                    <a href="{{ listing.attributes.url }}" class="button button-default">Reserve</a>
                  </li>
                </ul>
              </div>
            </article>
          {% endif %}
        {% endfor %}
      {% endfor %}
    </section>

    <div class="related-items">
      <h4>Related listings:</h4>
      <ul class="list-unstyled">
        {% for related_storage in dsc.data.first.relationships.popular_searches.data %}
          {% for included_link in dsc.included %}
            {% if included_link.id == related_storage.id %}
              <li><a href="{{ included_link.attributes.url }}" class="button button-default button-small">{{ included_link.attributes.highlighted }}</a></li>
              {% break %}
            {% endif %}
          {% endfor %}
        {% endfor %}
      </ul>
    </div>

  {% endif %}
{% endcache_for %}
            )
    end
  end
end
